import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions/v2';
import { recomputeDay } from './recomputeDay';
import { applyStreakUpdate } from './streak';
import { applyQazaDelta } from './qaza';

/**
 * 08 §2.2: on any write to a subject's prayer log, rebuild that day's
 * summary, then the streak, then (for qaza logs) the qaza counters.
 * Idempotent — safe to run more than once for the same write.
 */
async function handlePrayerWritten(
  subjectPath: string,
  dateKey: string,
  before: FirebaseFirestore.DocumentData | undefined,
  after: FirebaseFirestore.DocumentData | undefined,
): Promise<void> {
  const { before: beforeSummary, after: afterSummary } = await recomputeDay(subjectPath, dateKey);
  await applyStreakUpdate(subjectPath, beforeSummary, afterSummary);

  const type = after?.type ?? before?.type;
  if (type === 'qaza') {
    const prayerName = after?.prayerName ?? before?.prayerName;
    const beforeCount = typeof before?.count === 'number' ? before.count : 0;
    const afterCount = typeof after?.count === 'number' ? after.count : 0;
    if (prayerName) await applyQazaDelta(subjectPath, prayerName, afterCount - beforeCount);
  }

  logger.info({ fn: 'onPrayerWritten', subjectPath, dateKey });
}

export const onSelfPrayerWritten = onDocumentWritten('users/{uid}/prayers/{logId}', async (event) => {
  const dateKey = event.data?.after.data()?.dateKey ?? event.data?.before.data()?.dateKey;
  if (!dateKey) return;
  await handlePrayerWritten(
    `users/${event.params.uid}`,
    dateKey,
    event.data?.before.data(),
    event.data?.after.data(),
  );
});

export const onChildPrayerWritten = onDocumentWritten('children/{id}/prayers/{logId}', async (event) => {
  const dateKey = event.data?.after.data()?.dateKey ?? event.data?.before.data()?.dateKey;
  if (!dateKey) return;
  await handlePrayerWritten(
    `children/${event.params.id}`,
    dateKey,
    event.data?.before.data(),
    event.data?.after.data(),
  );
});

export const onStudentPrayerWritten = onDocumentWritten('students/{id}/prayers/{logId}', async (event) => {
  const dateKey = event.data?.after.data()?.dateKey ?? event.data?.before.data()?.dateKey;
  if (!dateKey) return;
  await handlePrayerWritten(
    `students/${event.params.id}`,
    dateKey,
    event.data?.before.data(),
    event.data?.after.data(),
  );
});
