const fs = require('fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { ref, uploadBytes, getBytes } = require('firebase/storage');

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'kindred-storage-test',
    firestore: { rules: fs.readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8080 },
    storage: { rules: fs.readFileSync('../storage.rules', 'utf8'), host: '127.0.0.1', port: 9199 },
  });
  await env.withSecurityRulesDisabled(async (context) => {
    const { doc, setDoc } = require('firebase/firestore');
    await setDoc(doc(context.firestore(), 'stories/s1'), { creatorId: 'owner', status: 'published', visibility: 'private' });
  });
});

afterAll(async () => env?.cleanup());

test('story owner can upload and read evidence storage', async () => {
  const storage = env.authenticatedContext('owner').storage();
  await assertSucceeds(uploadBytes(ref(storage, 'stories/s1/evidence/photo.jpg'), new Uint8Array([1, 2, 3])));
  await assertSucceeds(getBytes(ref(storage, 'stories/s1/evidence/photo.jpg')));
});

test('other users cannot upload or read private story evidence storage', async () => {
  const storage = env.authenticatedContext('other').storage();
  await assertFails(uploadBytes(ref(storage, 'stories/s1/evidence/blocked.jpg'), new Uint8Array([1])));
  await assertFails(getBytes(ref(storage, 'stories/s1/evidence/photo.jpg')));
});
