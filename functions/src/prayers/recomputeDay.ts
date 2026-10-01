import { db, FieldValue } from '../lib/admin';

const FARD_PRAYERS = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'] as const;

export interface DailySummaryData {
  dateKey: string;
  fardDone: number;
  fardMissed: number;
  fardUnmarked: number;
  fard: Record<string, string | null>;
  nawafilDone: number;
  qazaDone: number;
  perfect: boolean;
}

/**
 * 08 §2.2 `recomputeDay`. Rebuilds `{subject}/dailySummaries/{dateKey}` from
 * that day's logs. `set()` (not merge) so re-running it is always safe.
 *
 * Unlike the full spec, `fardUnmarked` here just means "no log yet" — it
 * doesn't yet know whether that prayer's window has ended, since that needs
 * the subject's location/calc method on the server (09 §1, not built yet).
 * Revisit once server-side prayer times land.
 */
export async function recomputeDay(
  subjectPath: string,
  dateKey: string,
): Promise<{ before: DailySummaryData | null; after: DailySummaryData }> {
  const summaryRef = db.doc(`${subjectPath}/dailySummaries/${dateKey}`);
  const [logsSnap, beforeSnap] = await Promise.all([
    db.collection(`${subjectPath}/prayers`).where('dateKey', '==', dateKey).get(),
    summaryRef.get(),
  ]);

  const fard: Record<string, string | null> = {};
  for (const p of FARD_PRAYERS) fard[p] = null;
  let nawafilDone = 0;
  let qazaDone = 0;

  for (const doc of logsSnap.docs) {
    const log = doc.data();
    if (log.type === 'fard' && FARD_PRAYERS.includes(log.prayerName)) {
      fard[log.prayerName] = log.status ?? null;
    } else if (log.type === 'nawafil' && log.status === 'completed') {
      nawafilDone += 1;
    } else if (log.type === 'qaza') {
      qazaDone += typeof log.count === 'number' ? log.count : 0;
    }
  }

  const fardDone = Object.values(fard).filter((s) => s === 'completed').length;
  const fardMissed = Object.values(fard).filter((s) => s === 'missed').length;
  const fardUnmarked = FARD_PRAYERS.length - fardDone - fardMissed;
  const perfect = fardDone === FARD_PRAYERS.length;

  const after: DailySummaryData = {
    dateKey,
    fardDone,
    fardMissed,
    fardUnmarked,
    fard,
    nawafilDone,
    qazaDone,
    perfect,
  };

  await summaryRef.set({ ...after, updatedAt: FieldValue.serverTimestamp() });

  return { before: beforeSnap.exists ? (beforeSnap.data() as DailySummaryData) : null, after };
}
