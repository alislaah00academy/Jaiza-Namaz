import test from 'node:test';
import assert from 'node:assert/strict';
import { defaultUserProfile } from '../src/auth/profileDefaults';

test('defaultUserProfile sets PK defaults and the individual mode (D-095)', () => {
  const profile = defaultUserProfile({
    uid: 'u1',
    email: 'Alice@Example.com',
    phone: null,
    name: 'Alice',
    today: '2026-01-05',
  });

  assert.equal(profile.uid, 'u1');
  assert.equal(profile.emailLower, 'alice@example.com');
  assert.deepEqual(profile.modes, { individual: true });
  assert.equal(profile.onboardedModes, false);
  assert.equal(profile.trackingSince, '2026-01-05');
  assert.equal(profile.prayerSettings.calcMethod, 'karachi');
  assert.equal(profile.prayerSettings.madhab, 'hanafi');
});

test('defaultUserProfile tolerates a missing name/email', () => {
  const profile = defaultUserProfile({ uid: 'u2', email: null, phone: null, name: null, today: '2026-01-05' });
  assert.equal(profile.name, '');
  assert.equal(profile.email, null);
  assert.equal(profile.emailLower, null);
});
