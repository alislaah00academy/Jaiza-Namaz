import { FieldValue } from '../lib/admin';

/** D-095: Pakistan-first defaults. Non-PK users pick their own in onboarding. */
export const DEFAULT_PRAYER_SETTINGS = {
  calcMethod: 'karachi',
  madhab: 'hanafi',
  useGps: true,
  notificationsEnabled: true,
  endReminderMinutes: 10,
};

export interface NewUserInput {
  uid: string;
  email: string | null;
  phone: string | null;
  name: string | null;
  today: string;
}

/** Pure — used by both `onUserCreated` and `ensureUserProfile` (08 §2.1). */
export function defaultUserProfile(input: NewUserInput) {
  return {
    uid: input.uid,
    name: input.name ?? '',
    email: input.email ?? null,
    emailLower: input.email ? input.email.toLowerCase() : null,
    phone: input.phone ?? null,
    modes: { individual: true },
    lastMode: 'individual',
    onboardedModes: false,
    nawafilEnabled: true,
    prayerSettings: DEFAULT_PRAYER_SETTINGS,
    qazaPlan: { perPrayer: {}, dailyGoal: 5, reminder: { enabled: false, time: '21:00' } },
    mosques: { primaryId: null, savedIds: [], changeAlerts: true },
    notificationPrefs: { announcements: true, changeAlerts: true },
    trackingSince: input.today,
    lastSeenAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}
