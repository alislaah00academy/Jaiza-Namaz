import test from 'node:test';
import assert from 'node:assert/strict';
import { newlyEarnedBadges } from '../src/lib/badges';

test('newlyEarnedBadges returns thresholds crossed for the first time', () => {
  const earned = newlyEarnedBadges([], { current: 7, nawafilTotal: 2 });
  assert.deepEqual(earned.sort(), ['first_step', 'week_warrior']);
});

test('newlyEarnedBadges excludes badges already earned', () => {
  const earned = newlyEarnedBadges(['first_step'], { current: 7, nawafilTotal: 2 });
  assert.deepEqual(earned, ['week_warrior']);
});

test('newlyEarnedBadges is empty below every threshold', () => {
  assert.deepEqual(newlyEarnedBadges([], { current: 0, nawafilTotal: 0 }), []);
});

test('nawafil_nur fires on nawafilTotal regardless of streak', () => {
  const earned = newlyEarnedBadges([], { current: 0, nawafilTotal: 10 });
  assert.deepEqual(earned, ['nawafil_nur']);
});
