// End-to-end check against the live emulators (Firestore + Functions): writes
// a prayer log the way the app would, then waits for onSelfPrayerWritten to
// produce dailySummaries / stats/streak / stats/qaza. Not part of `npm test`
// (needs --only firestore,functions); run via:
//   firebase emulators:exec --only firestore,functions --project jaiza-rules-test \
//     "node test/integration/prayerFlow.integration.cjs"
const assert = require('node:assert/strict');
const admin = require('firebase-admin');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const app = admin.initializeApp({ projectId: 'jaiza-rules-test' });
// Must match FIRESTORE_DATABASE_ID in src/config.ts, or the trigger (which
// reads/writes that same named database) and this script see different data.
const db = getFirestore(app, 'jaiza');

function todayKey() {
  const d = new Date();
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}`;
}

async function waitFor(fn, { tries = 40, delayMs = 250 } = {}) {
  for (let i = 0; i < tries; i++) {
    const result = await fn();
    if (result) return result;
    await new Promise((r) => setTimeout(r, delayMs));
  }
  throw new Error('waitFor: condition never became true');
}

async function main() {
  const uid = 'integration-user';
  const today = todayKey();
  const fardPrayers = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];

  for (const prayer of fardPrayers) {
    const logId = `${today}_${prayer}_fard`;
    await db.doc(`users/${uid}/prayers/${logId}`).set({
      dateKey: today,
      prayerName: prayer,
      type: 'fard',
      status: 'completed',
      markedBy: uid,
      source: 'app',
      markedAt: FieldValue.serverTimestamp(),
      dateTime: FieldValue.serverTimestamp(),
    });
  }

  const summary = await waitFor(async () => {
    const snap = await db.doc(`users/${uid}/dailySummaries/${today}`).get();
    return snap.exists && snap.data().fardDone === 5 ? snap.data() : null;
  });
  assert.equal(summary.fardDone, 5);
  assert.equal(summary.perfect, true);
  console.log('ok: dailySummaries reflects all 5 Fard as completed');

  const streak = await waitFor(async () => {
    const snap = await db.doc(`users/${uid}/stats/streak`).get();
    return snap.exists && snap.data().current >= 1 ? snap.data() : null;
  });
  assert.ok(streak.current >= 1, `expected current >= 1, got ${streak.current}`);
  assert.ok(streak.badges.includes('first_step'), 'expected first_step badge');
  console.log('ok: stats/streak shows current >= 1 and the first_step badge');

  const qazaLogId = `${today}_fajr_qaza`;
  await db.doc(`users/${uid}/prayers/${qazaLogId}`).set({
    dateKey: today,
    prayerName: 'fajr',
    type: 'qaza',
    count: 3,
    markedBy: uid,
    source: 'app',
    markedAt: FieldValue.serverTimestamp(),
    dateTime: FieldValue.serverTimestamp(),
  });

  const qaza = await waitFor(async () => {
    const snap = await db.doc(`users/${uid}/stats/qaza`).get();
    return snap.exists && snap.data().perPrayer?.fajr?.completed === 3 ? snap.data() : null;
  });
  assert.equal(qaza.perPrayer.fajr.completed, 3);
  console.log('ok: stats/qaza.perPrayer.fajr.completed reflects the qaza log count');

  console.log('\nAll integration checks passed.');
  process.exit(0);
}

main().catch((err) => {
  console.error('Integration check failed:', err);
  process.exit(1);
});
