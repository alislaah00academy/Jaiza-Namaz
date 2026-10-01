import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { z } from 'zod';
import { db, FieldValue } from '../lib/admin';
import { dateKeyOfUtc } from '../lib/dateKey';
import { defaultUserProfile } from './profileDefaults';

const Input = z.object({
  name: z.string().min(1).max(50).optional(),
  locale: z.enum(['en', 'ur']).optional(),
  timezone: z.string().min(1).max(64).optional(),
});

/**
 * 08 §2.1. Idempotent like `onUserCreated`, plus keeps `name/locale/timezone/
 * lastSeenAt` fresh and surfaces any pending invite for this verified email
 * (teacher or mosque-admin) so the app can offer to accept it.
 */
export const ensureUserProfile = onCall({ enforceAppCheck: false }, async (req) => {
  if (!req.auth) {
    throw new HttpsError('unauthenticated', 'Sign in first');
  }
  const input = Input.parse(req.data ?? {});
  const uid = req.auth.uid;
  const token = req.auth.token;
  const ref = db.doc(`users/${uid}`);
  const snap = await ref.get();

  if (!snap.exists) {
    await ref.set(
      defaultUserProfile({
        uid,
        email: (token.email as string | undefined) ?? null,
        phone: (token.phone_number as string | undefined) ?? null,
        name: input.name ?? null,
        today: dateKeyOfUtc(new Date()),
      }),
    );
  } else {
    await ref.set(
      {
        ...(input.name ? { name: input.name } : {}),
        ...(input.locale ? { locale: input.locale } : {}),
        ...(input.timezone ? { timezone: input.timezone } : {}),
        lastSeenAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  const result: { pendingTeacherInvite?: unknown; pendingMosqueAdminInvite?: unknown } = {};
  if (token.email_verified && token.email) {
    const emailLower = String(token.email).toLowerCase();
    const [teacherInvites, mosqueInvites] = await Promise.all([
      db
        .collectionGroup('invites')
        .where('email', '==', emailLower)
        .where('status', '==', 'pending')
        .limit(1)
        .get(),
      db
        .collectionGroup('adminInvites')
        .where('email', '==', emailLower)
        .limit(1)
        .get(),
    ]);
    if (!teacherInvites.empty) {
      const inv = teacherInvites.docs[0];
      const orgId = inv.ref.parent.parent?.id;
      const org = orgId ? (await db.doc(`organizations/${orgId}`).get()).data() : undefined;
      result.pendingTeacherInvite = { orgId, orgName: org?.name };
    }
    if (!mosqueInvites.empty) {
      const inv = mosqueInvites.docs[0];
      const mosqueId = inv.ref.parent.parent?.id;
      const mosque = mosqueId ? (await db.doc(`mosques/${mosqueId}`).get()).data() : undefined;
      result.pendingMosqueAdminInvite = { mosqueId, name: mosque?.name };
    }
  }

  logger.info({ fn: 'ensureUserProfile', uid, created: !snap.exists });
  return result;
});
