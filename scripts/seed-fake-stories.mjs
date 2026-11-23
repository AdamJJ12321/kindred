/**
 * One-shot seed: 3 new Auth users + 10 public stories across those
 * and 2 existing accounts. Uses Identity Toolkit (signup) + Firestore
 * REST with a Google Cloud access token (IAM bypasses client rules).
 *
 * Usage:
 *   $env:GCLOUD_ACCESS_TOKEN = (gcloud auth print-access-token)
 *   node scripts/seed-fake-stories.mjs
 */
const PROJECT = 'my1stapp-b4b47';
const API_KEY = 'AIzaSyCi9SPuWj09wM35JUEOyZJUkQmbSJH15Pg';
const PASSWORD = 'KindredDemo1!';

const existing = [
  {
    uid: 'QjO1kzXbytMUxIu4WHfgE0V8CX23',
    email: 'jinadam62@gmail.com',
    displayName: 'Adam Jin',
  },
  {
    uid: 'm74npTPpWmbvffGLf1RWCenSVGs2',
    email: 'jack.hogan99@gmail.com',
    displayName: 'Jack Hogan',
  },
];

const newAccounts = [
  {
    email: 'maya.chen.kindred@example.com',
    displayName: 'Maya Chen',
    preferredLanguage: 'en',
  },
  {
    email: 'lina.chen.kindred@example.com',
    displayName: 'Lina Chen',
    preferredLanguage: 'zh',
  },
  {
    email: 'omar.rivera.kindred@example.com',
    displayName: 'Omar Rivera',
    preferredLanguage: 'en',
  },
];

function storyDefs(creators) {
  // 10 stories: mix of family / local / cultural across all 5 creators
  const [a, b, c, d, e] = creators;
  return [
    {
      creatorId: a.uid,
      title: 'Sunday noodles near the old railway',
      description:
        'A family recipe and the neighborhood kitchen where it became tradition.',
      storyType: 'family',
      evidenceType: 'oral_account',
    },
    {
      creatorId: a.uid,
      title: 'Lanterns on Lunar New Year',
      description:
        'How our block hung red lanterns and shared stories late into the night.',
      storyType: 'cultural',
      evidenceType: 'firsthand_memory',
    },
    {
      creatorId: b.uid,
      title: 'The market fire of 1968',
      description:
        'Neighbors still talk about the night the corner market burned and who helped rebuild.',
      storyType: 'local',
      evidenceType: 'firsthand_memory',
    },
    {
      creatorId: b.uid,
      title: 'Grandmother’s sewing box',
      description:
        'Buttons, patterns, and letters kept in a wooden box passed through three generations.',
      storyType: 'family',
      evidenceType: 'documented_fact',
    },
    {
      creatorId: c.uid,
      title: 'Oakland Chinatown parade route',
      description:
        'Mapping the old parade streets and the shops that sponsored each float.',
      storyType: 'local',
      evidenceType: 'documented_fact',
    },
    {
      creatorId: c.uid,
      title: 'Mid-Autumn mooncakes at school',
      description:
        'A classroom tradition of sharing mooncakes and explaining the festival to friends.',
      storyType: 'cultural',
      evidenceType: 'oral_account',
    },
    {
      creatorId: d.uid,
      title: 'Harvest festival in the East Bay hills',
      description:
        'Songs, dances, and food stalls that return every autumn on the same hillside.',
      storyType: 'cultural',
      evidenceType: 'unverified_story',
    },
    {
      creatorId: d.uid,
      title: 'Auntie’s courtyard garden',
      description:
        'Medicinal herbs and tomato vines that fed the extended family each summer.',
      storyType: 'family',
      evidenceType: 'oral_account',
    },
    {
      creatorId: e.uid,
      title: 'When the trolley stopped on Fruitvale',
      description:
        'Local memory of the last trolley run and the shops that opened afterward.',
      storyType: 'local',
      evidenceType: 'firsthand_memory',
    },
    {
      creatorId: e.uid,
      title: 'Dia de los Muertos ofrenda at home',
      description:
        'Photos, marigolds, and favorite foods arranged for relatives remembered each November.',
      storyType: 'cultural',
      evidenceType: 'firsthand_memory',
    },
  ];
}

async function signUpOrSignIn(email, password) {
  const signUp = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  const signUpBody = await signUp.json();
  if (signUp.ok) {
    return { uid: signUpBody.localId, idToken: signUpBody.idToken, created: true };
  }
  if (signUpBody.error?.message === 'EMAIL_EXISTS') {
    const signIn = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, returnSecureToken: true }),
      },
    );
    const signInBody = await signIn.json();
    if (!signIn.ok) {
      throw new Error(`signIn failed for ${email}: ${JSON.stringify(signInBody)}`);
    }
    return { uid: signInBody.localId, idToken: signInBody.idToken, created: false };
  }
  throw new Error(`signUp failed for ${email}: ${JSON.stringify(signUpBody)}`);
}

function fsString(v) {
  return { stringValue: v };
}
function fsArray(strings) {
  return { arrayValue: { values: strings.map((s) => fsString(s)) } };
}
function fsTimestamp(date = new Date()) {
  return { timestampValue: date.toISOString() };
}

async function upsertUserProfile(accessToken, user) {
  const name = `projects/${PROJECT}/databases/(default)/documents/users/${user.uid}`;
  const url = `https://firestore.googleapis.com/v1/${name}?currentDocument.exists=false`;
  const patchUrl = `https://firestore.googleapis.com/v1/${name}?updateMask.fieldPaths=displayName&updateMask.fieldPaths=preferredLanguage&updateMask.fieldPaths=timeZone&updateMask.fieldPaths=updatedAt`;
  const fields = {
    displayName: fsString(user.displayName),
    preferredLanguage: fsString(user.preferredLanguage || 'en'),
    timeZone: fsString('America/Los_Angeles'),
    updatedAt: fsTimestamp(),
    createdAt: fsTimestamp(),
  };
  // Try create; if exists, patch
  let res = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });
  // Firestore create-via-patch with exists=false uses special query; simpler: always PATCH without mask create
  if (!res.ok) {
    res = await fetch(
      `https://firestore.googleapis.com/v1/${name}`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ fields }),
      },
    );
  }
  // Direct documents write:
  res = await fetch(`https://firestore.googleapis.com/v1/${name}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });
  if (!res.ok) {
    throw new Error(
      `profile ${user.uid}: ${res.status} ${await res.text()} (patchUrl unused=${patchUrl})`,
    );
  }
}

async function createStory(accessToken, story, index) {
  const now = new Date(Date.now() - index * 3600_000);
  const fields = {
    creatorId: fsString(story.creatorId),
    title: fsString(story.title),
    description: fsString(story.description),
    storyType: fsString(story.storyType),
    evidenceType: fsString(story.evidenceType),
    visibility: fsString('public'),
    status: fsString('published'),
    familyIds: fsArray([]),
    relatedStoryIds: fsArray([]),
    createdAt: fsTimestamp(now),
    updatedAt: fsTimestamp(now),
    publishedAt: fsTimestamp(now),
  };
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/stories`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ fields }),
    },
  );
  const body = await res.json();
  if (!res.ok) {
    throw new Error(`story create failed: ${JSON.stringify(body)}`);
  }
  return body.name?.split('/').pop();
}

async function main() {
  const accessToken = process.env.GCLOUD_ACCESS_TOKEN;
  if (!accessToken) {
    throw new Error('Set GCLOUD_ACCESS_TOKEN from: gcloud auth print-access-token');
  }

  const createdAccounts = [];
  for (const account of newAccounts) {
    const auth = await signUpOrSignIn(account.email, PASSWORD);
    createdAccounts.push({
      ...account,
      uid: auth.uid,
      password: PASSWORD,
      created: auth.created,
    });
    console.log(
      `${auth.created ? 'Created' : 'Found'} Auth user ${account.email} -> ${auth.uid}`,
    );
  }

  const creators = [
    existing[0],
    existing[1],
    createdAccounts[0],
    createdAccounts[1],
    createdAccounts[2],
  ];

  for (const user of creators) {
    await upsertUserProfile(accessToken, {
      uid: user.uid,
      displayName: user.displayName,
      preferredLanguage: user.preferredLanguage || 'en',
    });
    console.log(`Upserted profile users/${user.uid} (${user.displayName})`);
  }

  const stories = storyDefs(creators);
  const ids = [];
  for (let i = 0; i < stories.length; i++) {
    const id = await createStory(accessToken, stories[i], i);
    ids.push(id);
    console.log(
      `Story ${i + 1}/10 [${stories[i].storyType}] "${stories[i].title}" -> ${id} (creator ${stories[i].creatorId})`,
    );
  }

  console.log('\n=== Seed complete ===');
  console.log('Existing accounts (unchanged passwords):');
  for (const u of existing) console.log(`  ${u.email}  uid=${u.uid}`);
  console.log(`New demo accounts (password: ${PASSWORD}):`);
  for (const u of createdAccounts) console.log(`  ${u.email}  uid=${u.uid}`);
  console.log(`Stories written: ${ids.length}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
