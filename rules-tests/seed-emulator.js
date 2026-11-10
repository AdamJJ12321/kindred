const fs = require('fs');
const { initializeApp } = require('firebase/app');
const { getFirestore, connectFirestoreEmulator, doc, setDoc } = require('firebase/firestore');

const seed = JSON.parse(fs.readFileSync('../seed-data.json', 'utf8'));
const app = initializeApp({ projectId: 'kindred-local' });
const db = getFirestore(app);
connectFirestoreEmulator(db, '127.0.0.1', 8080);

(async () => {
  for (const [collection, records] of Object.entries(seed)) {
    for (const [id, data] of Object.entries(records)) {
      await setDoc(doc(db, collection, id), data);
    }
  }
  console.log('Seeded Auth/Firestore local Firestore records.');
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
