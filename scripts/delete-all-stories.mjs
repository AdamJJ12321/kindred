/**
 * Deletes every document in stories/ (and evidence subcollections).
 * Usage:
 *   $env:GCLOUD_ACCESS_TOKEN = (gcloud auth print-access-token)
 *   node scripts/delete-all-stories.mjs
 */
const PROJECT = 'my1stapp-b4b47';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

async function listCollection(path, pageToken) {
  const url = new URL(`${BASE}/${path}`);
  url.searchParams.set('pageSize', '100');
  if (pageToken) url.searchParams.set('pageToken', pageToken);
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${process.env.GCLOUD_ACCESS_TOKEN}` },
  });
  const body = await res.json();
  if (!res.ok) throw new Error(JSON.stringify(body));
  return body;
}

async function deleteDoc(name) {
  const res = await fetch(`https://firestore.googleapis.com/v1/${name}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${process.env.GCLOUD_ACCESS_TOKEN}` },
  });
  if (!res.ok && res.status !== 404) {
    throw new Error(`${res.status} ${await res.text()}`);
  }
}

async function deleteStory(docName) {
  const storyId = docName.split('/').pop();
  let token;
  do {
    const page = await listCollection(`stories/${storyId}/evidence`, token);
    for (const doc of page.documents || []) {
      await deleteDoc(doc.name);
      console.log(`  deleted evidence ${doc.name.split('/').pop()}`);
    }
    token = page.nextPageToken;
  } while (token);
  await deleteDoc(docName);
  console.log(`deleted story ${storyId}`);
}

async function main() {
  if (!process.env.GCLOUD_ACCESS_TOKEN) {
    throw new Error('Set GCLOUD_ACCESS_TOKEN');
  }
  let token;
  let count = 0;
  do {
    const page = await listCollection('stories', token);
    for (const doc of page.documents || []) {
      await deleteStory(doc.name);
      count++;
    }
    token = page.nextPageToken;
  } while (token);
  console.log(`Done. Deleted ${count} stories.`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
