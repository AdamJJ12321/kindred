const fs = require('fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, setDoc } = require('firebase/firestore');
const { ref, uploadBytes, getBytes } = require('firebase/storage');

let env;
beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'kindred-storage-rules-test',
    firestore: { rules: fs.readFileSync('../firestore.rules', 'utf8') },
    storage: { rules: fs.readFileSync('../storage.rules', 'utf8') },
  });
});
afterAll(async () => env.cleanup());
afterEach(async () => env.clearFirestore());

test('story owner can upload evidence and unauthorized user cannot read it', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'stories/story'), {
      creatorId: 'owner', status: 'published', visibility: 'private', title: 'Private story',
    });
  });
  const ownerStorage = env.authenticatedContext('owner').storage();
  await assertSucceeds(uploadBytes(ref(ownerStorage, 'stories/story/evidence/photo.jpg'), new Uint8Array([1, 2, 3]), { contentType: 'image/jpeg' }));
  await assertFails(getBytes(ref(env.authenticatedContext('other').storage(), 'stories/story/evidence/photo.jpg')));
});
