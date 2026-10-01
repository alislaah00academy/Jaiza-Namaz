import test from 'node:test';
import assert from 'node:assert/strict';
import { isValidDateKey, addDays, daysBetween, dateKeyOfUtc } from '../src/lib/dateKey';

test('dateKeyOfUtc pads year, month and day', () => {
  assert.equal(dateKeyOfUtc(new Date(Date.UTC(2026, 0, 5))), '2026-01-05');
});

test('isValidDateKey rejects malformed and impossible dates', () => {
  assert.equal(isValidDateKey('2026-02-30'), false);
  assert.equal(isValidDateKey('not-a-date'), false);
  assert.equal(isValidDateKey('2026-2-5'), false);
  assert.equal(isValidDateKey('2026-02-28'), true);
});

test('addDays crosses month and year boundaries', () => {
  assert.equal(addDays('2026-01-31', 1), '2026-02-01');
  assert.equal(addDays('2026-12-31', 1), '2027-01-01');
  assert.equal(addDays('2026-03-01', -1), '2026-02-28');
});

test('daysBetween is positive when `to` is later', () => {
  assert.equal(daysBetween('2026-01-01', '2026-01-08'), 7);
  assert.equal(daysBetween('2026-01-08', '2026-01-01'), -7);
});
