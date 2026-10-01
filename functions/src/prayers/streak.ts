import { db, FieldValue } from '../lib/admin';
import { addDays, dateKeyOfUtc } from '../lib/dateKey';
import { newlyEarnedBadges } from '../lib/badges';
import type { DailySummaryData } from './recomputeDay';

const MAX_LOOKBACK_DAYS = 400;

/**
 * 09 §5: "current" = perfect days in a row ending today-or-yesterday (today
 * doesn't break the streak until its window is over). Walks back from today
 * through `dailySummaries` until the first non-perfect/missing day. Cheap in
 * practice because marks are limited to the last 8 days (D-075) — a longer
 * streak was already correct before today's write.
 */
export async function recomputeCurrentStreak(
  subjectPath: string,
  now: Date = new Date(),
): Promise<{ current: number; lastPerfectDateKey: string | null }> {
  const today = dateKeyOfUtc(now);
  let cursor = today;
  let current = 0;
  let lastPerfectDateKey: string | null = null;
  let skippedToday = false;

  for (let i = 0; i < MAX_LOOKBACK_DAYS; i++) {
    const snap = await db.doc(`${subjectPath}/dailySummaries/${cursor}`).get();
    const perfect = snap.exists && snap.data()?.perfect === true;
    if (perfect) {
      current += 1;
      if (lastPerfectDateKey === null) lastPerfectDateKey = cursor;
      cursor = addDays(cursor, -1);
      continue;
    }
    if (cursor === today && !skippedToday) {
      skippedToday = true;
      cursor = addDays(cursor, -1);
      continue;
    }
    break;
  }
  return { current, lastPerfectDateKey };
}

export interface StreakStatsData {
  current: number;
  longest: number;
  lastPerfectDateKey: string | null;
  badges: string[];
  nawafilTotal: number;
}

/**
 * Applies the day's nawafil delta and the freshly walked `current`/`longest`/
 * badges to `{subject}/stats/streak`, in one transaction.
 */
export async function applyStreakUpdate(
  subjectPath: string,
  before: DailySummaryData | null,
  after: DailySummaryData,
  now: Date = new Date(),
): Promise<void> {
  const { current, lastPerfectDateKey } = await recomputeCurrentStreak(subjectPath, now);
  const ref = db.doc(`${subjectPath}/stats/streak`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const existing: StreakStatsData = snap.exists
      ? (snap.data() as StreakStatsData)
      : { current: 0, longest: 0, lastPerfectDateKey: null, badges: [], nawafilTotal: 0 };

    const nawafilTotal = existing.nawafilTotal + (after.nawafilDone - (before?.nawafilDone ?? 0));
    const longest = Math.max(existing.longest, current);
    const newBadges = newlyEarnedBadges(existing.badges, { current, nawafilTotal });
    const badges = newBadges.length ? [...existing.badges, ...newBadges] : existing.badges;

    tx.set(ref, {
      current,
      longest,
      lastPerfectDateKey: lastPerfectDateKey ?? existing.lastPerfectDateKey,
      badges,
      nawafilTotal,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
