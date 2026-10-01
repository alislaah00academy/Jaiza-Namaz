import { auth as authTrigger } from 'firebase-functions/v1';
import { logger } from 'firebase-functions/v2';
import { db } from '../lib/admin';
import { dateKeyOfUtc } from '../lib/dateKey';
import { defaultUserProfile } from './profileDefaults';

/**
 * 08 §2.1. v1 Auth trigger — creates `users/{uid}` with defaults if it
 * doesn't exist yet. Idempotent: a user who already has a profile (e.g.
 * re-created via `ensureUserProfile`) is left untouched.
 */
export const onUserCreated = authTrigger.user().onCreate(async (user) => {
  const ref = db.doc(`users/${user.uid}`);
  const existing = await ref.get();
  if (existing.exists) {
    logger.info({ fn: 'onUserCreated', uid: user.uid, skipped: true });
    return;
  }

  await ref.set(
    defaultUserProfile({
      uid: user.uid,
      email: user.email ?? null,
      phone: user.phoneNumber ?? null,
      name: user.displayName ?? null,
      today: dateKeyOfUtc(new Date()),
    }),
  );
  logger.info({ fn: 'onUserCreated', uid: user.uid });
});
