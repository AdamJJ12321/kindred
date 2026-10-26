const fs = require('fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc } = require('firebase/firestore');

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'kindred-rules-test',
    firestore: { rules: fs.readFileSync('../firestore.rules', 'utf8') },
  });
});

afterAll(async () => env.cleanup());
afterEach(async () => env.clearFirestore());

test('public published stories can be read without auth', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'stories/public'), {
      creatorId: 'owner', status: 'published', visibility: 'public', title: 'Public story',
    });
  });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'stories/public')));
});

test('private stories reject unauthorized reads', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'stories/private'), {
      creatorId: 'owner', status: 'published', visibility: 'private', title: 'Private story',
    });
  });
  await assertFails(getDoc(doc(env.authenticatedContext('other').firestore(), 'stories/private')));
  await assertSucceeds(getDoc(doc(env.authenticatedContext('owner').firestore(), 'stories/private')));
});

test('only the owner can create a story for their uid', async () => {
  const owner = env.authenticatedContext('owner').firestore();
  await assertSucceeds(setDoc(doc(owner, 'stories/new'), { creatorId: 'owner', status: 'draft', visibility: 'private' }));
  const other = env.authenticatedContext('other').firestore();
  await assertFails(setDoc(doc(other, 'stories/forged'), { creatorId: 'owner', status: 'draft', visibility: 'private' }));
});
