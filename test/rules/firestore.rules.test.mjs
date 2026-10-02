// Rules tests for docs/system-design/07-security-rules.md §4 checklist.
// Run: npm install && npm test  (needs the Firestore emulator on :8080 —
// `firebase emulators:exec --only firestore "npm --prefix test/rules test"`)
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  increment,
  serverTimestamp,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rulesPath = join(__dirname, '..', '..', 'firestore.rules');

function dateKey(offsetDays = 0) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().slice(0, 10);
}

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'jaiza-rules-test',
    firestore: {
      rules: readFileSync(rulesPath, 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

async function seed(fn) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

// ---------- users ----------

test('a user cannot write another user\'s profile doc', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  await assertFails(setDoc(doc(alice, 'users/bob'), { name: 'x' }));
});

test('a user cannot change their own privileged fields (modes)', async () => {
  await seed((db) => setDoc(doc(db, 'users/alice'), { modes: ['individual'], name: 'Alice' }));
  const alice = testEnv.authenticatedContext('alice').firestore();
  await assertFails(updateDoc(doc(alice, 'users/alice'), { modes: ['individual', 'parent'] }));
  await assertSucceeds(updateDoc(doc(alice, 'users/alice'), { name: 'Alice A.' }));
});

// ---------- prayer logs: self (users/{uid}/prayers) ----------

test('a user can mark their own log inside the edit window with a valid id', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await assertSucceeds(
    setDoc(doc(alice, `users/alice/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'alice',
      markedAt: serverTimestamp(),
    }),
  );
});

test('a user cannot mark a log outside the 8-day edit window', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const old = dateKey(-10);
  const logId = `${old}_fajr_fard`;
  await assertFails(
    setDoc(doc(alice, `users/alice/prayers/${logId}`), {
      dateKey: old,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'alice',
      markedAt: serverTimestamp(),
    }),
  );
});

test('a user cannot mark a log whose id does not match its own fields', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await assertFails(
    setDoc(doc(alice, `users/alice/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'zuhr', // mismatched with the id
      type: 'fard',
      status: 'completed',
      markedBy: 'alice',
      markedAt: serverTimestamp(),
    }),
  );
});

test('a stranger cannot read or write another user\'s prayer log', async () => {
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await seed((db) =>
    setDoc(doc(db, `users/alice/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'alice',
    }),
  );
  const mallory = testEnv.authenticatedContext('mallory').firestore();
  await assertFails(getDoc(doc(mallory, `users/alice/prayers/${logId}`)));
  await assertFails(deleteDoc(doc(mallory, `users/alice/prayers/${logId}`)));
});

// ---------- qaza count increments (09 §4.2) ----------

test('qaza logs accept merge + increment (as the app writes them) and cap at 50', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const today = dateKey(0);
  const ref = doc(alice, `users/alice/prayers/${today}_fajr_qaza`);
  const base = {
    dateKey: today,
    prayerName: 'fajr',
    type: 'qaza',
    markedBy: 'alice',
    source: 'app',
    markedAt: serverTimestamp(),
    dateTime: new Date(),
  };
  await assertSucceeds(setDoc(ref, { ...base, count: increment(3) }, { merge: true }));
  await assertSucceeds(setDoc(ref, { ...base, count: increment(2) }, { merge: true }));
  assert.equal((await assertSucceeds(getDoc(ref))).data().count, 5);
  await assertFails(setDoc(ref, { ...base, count: increment(46) }, { merge: true }));
});

// ---------- children (Parent mode) ----------

test('a guardian can mark a child\'s log; a non-guardian cannot read it', async () => {
  await seed((db) =>
    setDoc(doc(db, 'children/child1'), { guardianUids: ['parent1'], name: 'Zain', createdBy: 'parent1' }),
  );
  const parent1 = testEnv.authenticatedContext('parent1').firestore();
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await assertSucceeds(
    setDoc(doc(parent1, `children/child1/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'parent1',
    }),
  );

  const stranger = testEnv.authenticatedContext('stranger').firestore();
  await assertFails(getDoc(doc(stranger, `children/child1/prayers/${logId}`)));
});

test('a second guardian added after the fact can read; after removal they cannot', async () => {
  await seed((db) =>
    setDoc(doc(db, 'children/child1'), { guardianUids: ['parent1', 'parent2'], name: 'Zain', createdBy: 'parent1' }),
  );
  const parent2 = testEnv.authenticatedContext('parent2').firestore();
  await assertSucceeds(getDoc(doc(parent2, 'children/child1')));

  await seed((db) => setDoc(doc(db, 'children/child1'), { guardianUids: ['parent1'], name: 'Zain', createdBy: 'parent1' }));
  await assertFails(getDoc(doc(parent2, 'children/child1')));
});

// ---------- organizations / teachers / students ----------

test('a stranger cannot claim an invite or create a teacher doc for themselves', async () => {
  await seed((db) => setDoc(doc(db, 'organizations/org1'), { adminUid: 'admin1', name: 'Org' }));
  const mallory = testEnv.authenticatedContext('mallory').firestore();
  await assertFails(
    updateDoc(doc(mallory, 'organizations/org1/invites/mallory@example.com'), { status: 'claimed' }),
  );
  await assertFails(setDoc(doc(mallory, 'organizations/org1/teachers/mallory'), {}));
});

test('a teacher can mark only their class\'s students; another teacher of the same org cannot', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'organizations/org1'), { adminUid: 'admin1', name: 'Org' });
    await setDoc(doc(db, 'organizations/org1/teachers/teacherA'), {});
    await setDoc(doc(db, 'organizations/org1/teachers/teacherB'), {});
    await setDoc(doc(db, 'students/student1'), {
      teacherUid: 'teacherA',
      orgId: 'org1',
      guardianUids: [],
    });
  });
  const teacherA = testEnv.authenticatedContext('teacherA').firestore();
  const teacherB = testEnv.authenticatedContext('teacherB').firestore();
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await assertSucceeds(
    setDoc(doc(teacherA, `students/student1/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'teacherA',
    }),
  );
  await assertFails(
    setDoc(doc(teacherB, `students/student1/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'teacherB',
    }),
  );
});

test('a linked guardian can read a student\'s logs but not write them', async () => {
  const today = dateKey(0);
  const logId = `${today}_fajr_fard`;
  await seed(async (db) => {
    await setDoc(doc(db, 'organizations/org1'), { adminUid: 'admin1', name: 'Org' });
    await setDoc(doc(db, 'students/student1'), {
      teacherUid: 'teacherA',
      orgId: 'org1',
      guardianUids: ['parent1'],
    });
    await setDoc(doc(db, `students/student1/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'completed',
      markedBy: 'teacherA',
    });
  });
  const parent1 = testEnv.authenticatedContext('parent1').firestore();
  await assertSucceeds(getDoc(doc(parent1, `students/student1/prayers/${logId}`)));
  await assertFails(
    setDoc(doc(parent1, `students/student1/prayers/${logId}`), {
      dateKey: today,
      prayerName: 'fajr',
      type: 'fard',
      status: 'missed',
      markedBy: 'parent1',
    }),
  );
});

// ---------- mosques (guest access) ----------

test('a guest can read a listed mosque but not an unlisted one, and not mosqueRequests', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'mosques/listed1'), { listed: true, adminUids: ['admin1'] });
    await setDoc(doc(db, 'mosques/hidden1'), { listed: false, adminUids: ['admin1'] });
    await setDoc(doc(db, 'mosqueRequests/req1'), { requesterUid: 'someone', status: 'pending' });
  });
  const guest = testEnv.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(guest, 'mosques/listed1')));
  await assertFails(getDoc(doc(guest, 'mosques/hidden1')));
  await assertFails(getDoc(doc(guest, 'mosqueRequests/req1')));
});

test('a mosque admin can publish a valid Jama\'at update; a non-admin cannot', async () => {
  const jamaat = { fajr: { type: 'fixed', time: '05:15' } };
  await seed((db) =>
    setDoc(doc(db, 'mosques/m1'), {
      listed: true,
      adminUids: ['admin1'],
      jamaat: {},
      jamaatVersion: 1,
      jumuah: [],
      upcoming: [],
    }),
  );
  const admin1 = testEnv.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(admin1, 'mosques/m1'), {
      jamaat,
      jamaatVersion: 2,
      jamaatUpdatedBy: 'admin1',
      jamaatUpdatedAt: serverTimestamp(),
    }),
  );

  const outsider = testEnv.authenticatedContext('outsider').firestore();
  await assertFails(
    updateDoc(doc(outsider, 'mosques/m1'), {
      jamaat,
      jamaatVersion: 3,
      jamaatUpdatedBy: 'outsider',
      jamaatUpdatedAt: serverTimestamp(),
    }),
  );
});

// ---------- platform-only collections ----------

test('nobody can read mosqueRequestsPrivate or linkCodes', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'mosqueRequestsPrivate/req1'), { cnic: '00000-0000000-0' });
    await setDoc(doc(db, 'linkCodes/abc123'), { studentId: 'student1' });
  });
  const alice = testEnv.authenticatedContext('alice').firestore();
  await assertFails(getDoc(doc(alice, 'mosqueRequestsPrivate/req1')));
  await assertFails(getDoc(doc(alice, 'linkCodes/abc123')));
});
