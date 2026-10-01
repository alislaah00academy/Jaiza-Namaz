import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({ region: 'asia-south1', maxInstances: 10, memory: '256MiB' });

export const TZ_PK = 'Asia/Karachi';

export const FIRESTORE_DATABASE_ID = 'jaiza';
