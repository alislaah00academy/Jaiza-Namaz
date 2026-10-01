/**
 * `dateKey` helpers — mirrors `jaiza_core`'s `DateKeys` (09 §2). Functions
 * never choose a prayer's dateKey (clients do, D-072); these only validate
 * and do calendar arithmetic on keys that already exist.
 */

const PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/;
export const MARKABLE_DAYS_BACK = 7;

export function isValidDateKey(key: string): boolean {
  const m = PATTERN.exec(key);
  if (!m) return false;
  const y = Number(m[1]);
  const mo = Number(m[2]);
  const d = Number(m[3]);
  const date = new Date(Date.UTC(y, mo - 1, d));
  return date.getUTCFullYear() === y && date.getUTCMonth() === mo - 1 && date.getUTCDate() === d;
}

export function pad(v: number, width: number): string {
  return String(v).padStart(width, '0');
}

export function dateKeyOfUtc(d: Date): string {
  return `${pad(d.getUTCFullYear(), 4)}-${pad(d.getUTCMonth() + 1, 2)}-${pad(d.getUTCDate(), 2)}`;
}

export function addDays(key: string, days: number): string {
  const m = PATTERN.exec(key);
  if (!m) throw new Error(`Not a dateKey: ${key}`);
  const d = new Date(Date.UTC(Number(m[1]), Number(m[2]) - 1, Number(m[3]) + days));
  return dateKeyOfUtc(d);
}

export function daysBetween(from: string, to: string): number {
  const a = PATTERN.exec(from);
  const b = PATTERN.exec(to);
  if (!a || !b) throw new Error('Not a dateKey');
  const da = Date.UTC(Number(a[1]), Number(a[2]) - 1, Number(a[3]));
  const db = Date.UTC(Number(b[1]), Number(b[2]) - 1, Number(b[3]));
  return Math.round((db - da) / 86_400_000);
}
