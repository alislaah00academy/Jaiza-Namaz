import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue } from 'firebase-admin/firestore';
import { FIRESTORE_DATABASE_ID } from '../config';

initializeApp();

export const db = getFirestore(FIRESTORE_DATABASE_ID);
export const auth = getAuth();
export { FieldValue };
