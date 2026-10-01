/** 09 §5. Thresholds only — once earned a badge is never removed (checked by the caller). */
export const BADGE_DEFINITIONS: Record<
  string,
  (s: { current: number; nawafilTotal: number }) => boolean
> = {
  first_step: (s) => s.current >= 1,
  week_warrior: (s) => s.current >= 7,
  month_light: (s) => s.current >= 30,
  nawafil_nur: (s) => s.nawafilTotal >= 10,
};

/** Badge ids newly earned given the current stats, excluding ones already in `existing`. */
export function newlyEarnedBadges(
  existing: readonly string[],
  stats: { current: number; nawafilTotal: number },
): string[] {
  return Object.entries(BADGE_DEFINITIONS)
    .filter(([id, isEarned]) => !existing.includes(id) && isEarned(stats))
    .map(([id]) => id);
}
