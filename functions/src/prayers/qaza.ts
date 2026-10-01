import { db, FieldValue } from '../lib/admin';

export interface QazaPrayerStatData {
  estimate: number;
  trackedMissed: number;
  completed: number;
  remaining: number;
}

/**
 * 09 §4.3 `completed[p]`, kept incrementally from each qaza log's count
 * delta. `trackedMissed` is **not** computed yet — that needs server-side
 * prayer-window-end detection (09 §1), which isn't built. It stays at
 * whatever a later maintenance script sets, defaulting to 0, so
 * `remaining` undercounts qaza from missed windows for now. Flagged for the
 * prayer-times phase.
 */
export async function applyQazaDelta(
  subjectPath: string,
  prayerName: string,
  countDelta: number,
): Promise<void> {
  if (countDelta === 0) return;
  const ref = db.doc(`${subjectPath}/stats/qaza`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.exists ? snap.data()! : { perPrayer: {}, totalRemaining: 0 };
    const perPrayer: Record<string, QazaPrayerStatData> = data.perPrayer ?? {};
    const existing: QazaPrayerStatData = perPrayer[prayerName] ?? {
      estimate: 0,
      trackedMissed: 0,
      completed: 0,
      remaining: 0,
    };

    const completed = Math.max(0, existing.completed + countDelta);
    const remaining = Math.max(0, existing.estimate + existing.trackedMissed - completed);
    perPrayer[prayerName] = { ...existing, completed, remaining };

    const totalRemaining = Object.values(perPrayer).reduce((sum, p) => sum + p.remaining, 0);

    tx.set(ref, { perPrayer, totalRemaining, updatedAt: FieldValue.serverTimestamp() });
  });
}
