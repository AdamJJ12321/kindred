const fs = require('fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, updateDoc, deleteDoc } = require('firebase/firestore');

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'kindred-rules-test',
    firestore: { rules: fs.readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8080 },
  });
});

afterAll(async () => env?.cleanup());
afterEach(async () => env?.clearFirestore());

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
  await assertSucceeds(getDoc(doc(owner, 'stories/new')));
  await assertFails(getDoc(doc(other, 'stories/new')));
});

test('evidence follows parent story access and cannot spoof uploader', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'stories/s1'), { creatorId: 'owner', status: 'published', visibility: 'public' });
    await setDoc(doc(context.firestore(), 'stories/s1/evidence/e1'), { kind: 'oral_account', uploadedBy: 'owner' });
  });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'stories/s1/evidence/e1')));
  await assertSucceeds(setDoc(doc(env.authenticatedContext('owner').firestore(), 'stories/s1/evidence/e2'), { kind: 'document', uploadedBy: 'owner' }));
  await assertFails(setDoc(doc(env.authenticatedContext('other').firestore(), 'stories/s1/evidence/e3'), { kind: 'document', uploadedBy: 'owner' }));
});

test('invited and family stories are limited to allowed readers', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'stories/invited'), { creatorId: 'owner', status: 'published', visibility: 'invited', allowedUserIds: ['guest'] });
    await setDoc(doc(context.firestore(), 'stories/family'), { creatorId: 'owner', status: 'published', visibility: 'family', familyMemberIds: ['member'] });
  });
  await assertSucceeds(getDoc(doc(env.authenticatedContext('guest').firestore(), 'stories/invited')));
  await assertFails(getDoc(doc(env.authenticatedContext('other').firestore(), 'stories/invited')));
  await assertSucceeds(getDoc(doc(env.authenticatedContext('member').firestore(), 'stories/family')));
  await assertFails(getDoc(doc(env.authenticatedContext('other').firestore(), 'stories/family')));
});

test('only owners update/delete stories and users own profiles', async () => {
  await env.withSecurityRulesDisabled(async (context) => await setDoc(doc(context.firestore(), 'stories/owned'), { creatorId: 'owner', status: 'published', visibility: 'public' }));
  await assertSucceeds(updateDoc(doc(env.authenticatedContext('owner').firestore(), 'stories/owned'), { title: 'updated' }));
  await assertFails(updateDoc(doc(env.authenticatedContext('other').firestore(), 'stories/owned'), { title: 'nope' }));
  await assertSucceeds(setDoc(doc(env.authenticatedContext('owner').firestore(), 'users/owner'), { displayName: 'Owner' }));
  await assertFails(getDoc(doc(env.authenticatedContext('other').firestore(), 'users/owner')));
  await assertFails(deleteDoc(doc(env.authenticatedContext('other').firestore(), 'stories/owned')));
});

test('families, questions and timeline permissions are enforced', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'families/f1'), { ownerId: 'owner', visibility: 'public' });
    await setDoc(doc(context.firestore(), 'families/f1/members/member'), { status: 'active' });
    await setDoc(doc(context.firestore(), 'dailyQuestions/q1'), { prompt: 'Question' });
  });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'families/f1')));
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'dailyQuestions/q1')));
  await assertFails(setDoc(doc(env.authenticatedContext('user').firestore(), 'dailyQuestions/q2'), { prompt: 'no' }));
  await assertSucceeds(setDoc(doc(env.authenticatedContext('owner').firestore(), 'families/f1/members/member2'), { status: 'active' }));
  await assertFails(setDoc(doc(env.authenticatedContext('member').firestore(), 'families/f1/members/member2'), { status: 'active' }));
  await assertSucceeds(setDoc(doc(env.authenticatedContext('user').firestore(), 'timelineEvents/e1'), { createdBy: 'user', date: { start: '2026-01-01' } }));
  await assertFails(updateDoc(doc(env.authenticatedContext('other').firestore(), 'timelineEvents/e1'), { title: 'no' }));
});
