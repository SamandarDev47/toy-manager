const admin = require('firebase-admin');

const DEFAULT_DATABASE_URL = 'https://toy-manager-default-rtdb.firebaseio.com';
const TIME_ZONE = 'Asia/Tashkent';

function readServiceAccount() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw || !raw.trim()) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT secret topilmadi. GitHub Secrets ichiga Firebase service account JSON ni kiriting.');
  }

  const value = raw.trim();
  try {
    return JSON.parse(value);
  } catch (_) {
    try {
      return JSON.parse(Buffer.from(value, 'base64').toString('utf8'));
    } catch (e) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT noto‘g‘ri. Full JSON yoki base64 JSON bo‘lishi kerak.');
    }
  }
}

function formatDateInTashkent(date) {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: TIME_ZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(date);
  const map = Object.fromEntries(parts.map((p) => [p.type, p.value]));
  return `${map.year}-${map.month}-${map.day}`;
}

function addDays(date, days) {
  const d = new Date(date.getTime());
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

function normalizeDate(value) {
  if (!value) return '';
  const raw = String(value).trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return raw;

  let match = raw.match(/^(\d{2})[.\-/](\d{2})[.\-/](\d{4})$/);
  if (match) {
    const [, dd, mm, yyyy] = match;
    return `${yyyy}-${mm}-${dd}`;
  }

  match = raw.match(/^(\d{4})[.\/](\d{2})[.\/](\d{2})$/);
  if (match) {
    const [, yyyy, mm, dd] = match;
    return `${yyyy}-${mm}-${dd}`;
  }

  const parsed = new Date(raw);
  if (!Number.isNaN(parsed.getTime())) return formatDateInTashkent(parsed);
  return raw;
}

function tokenEntriesFromSnapshot(value) {
  const tokens = [];
  if (!value || typeof value !== 'object') return tokens;

  for (const [uid, item] of Object.entries(value)) {
    if (typeof item === 'string' && item.trim()) {
      tokens.push({ uid, token: item.trim() });
    } else if (item && typeof item === 'object' && item.token) {
      tokens.push({ uid, token: String(item.token).trim() });
    }
  }

  const seen = new Set();
  return tokens.filter((entry) => {
    if (!entry.token || seen.has(entry.token)) return false;
    seen.add(entry.token);
    return true;
  });
}

function chunk(array, size) {
  const result = [];
  for (let i = 0; i < array.length; i += size) result.push(array.slice(i, i + size));
  return result;
}

function weddingTitle(wedding) {
  return wedding.eventName || wedding.weddingType || wedding.owner || 'To‘y';
}

function weddingBody(wedding) {
  const parts = [];
  if (wedding.location) parts.push(wedding.location);
  if (wedding.timeOfDay) parts.push(wedding.timeOfDay);
  if (wedding.time) parts.push(wedding.time);
  const details = parts.join(' • ');
  return details
    ? `Ertaga ${details} to‘y bor. Ilovaga bir qarang.`
    : 'Ertaga to‘y bor. Ilovaga bir qarang.';
}

async function removeInvalidTokens(sendResponses, entries) {
  const updates = {};
  sendResponses.forEach((response, index) => {
    if (response.success) return;
    const code = response.error && response.error.code;
    if (code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token') {
      const entry = entries[index];
      if (entry && entry.uid) updates[`userTokens/${entry.uid}`] = null;
    }
  });

  if (Object.keys(updates).length > 0) {
    await admin.database().ref().update(updates);
    console.log(`Invalid tokenlar tozalandi: ${Object.keys(updates).length}`);
  }
}

async function sendTomorrowWeddingNotifications() {
  const db = admin.database();
  const targetDate = process.env.TARGET_DATE || formatDateInTashkent(addDays(new Date(), 1));
  console.log(`Ertangi to‘y sanasi tekshirilyapti: ${targetDate}`);

  const [weddingsSnap, tokensSnap, logsSnap] = await Promise.all([
    db.ref('weddings').once('value'),
    db.ref('userTokens').once('value'),
    db.ref(`notificationLogs/tomorrowWedding/${targetDate}`).once('value'),
  ]);

  const weddings = weddingsSnap.val() || {};
  const tokenEntries = tokenEntriesFromSnapshot(tokensSnap.val());
  const alreadySent = logsSnap.val() || {};

  if (tokenEntries.length === 0) {
    console.log('FCM token topilmadi. Appga kamida bitta user kirib token saqlashi kerak.');
    return;
  }

  const weddingEntries = Object.entries(weddings).filter(([id, wedding]) => {
    if (!wedding || typeof wedding !== 'object') return false;
    if (alreadySent[id]) return false;
    if (String(wedding.status || 'active') === 'archived') return false;
    return normalizeDate(wedding.date) === targetDate;
  });

  if (weddingEntries.length === 0) {
    console.log('Ertaga notification yuboriladigan yangi to‘y topilmadi.');
    return;
  }

  for (const [weddingId, wedding] of weddingEntries) {
    console.log(`Notification yuborilmoqda: ${weddingId} - ${weddingTitle(wedding)}`);

    let successCount = 0;
    let failureCount = 0;
    for (const tokenChunk of chunk(tokenEntries, 500)) {
      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokenChunk.map((entry) => entry.token),
        notification: {
          title: `Ertaga to‘y bor: ${weddingTitle(wedding)} 💍`,
          body: weddingBody(wedding),
        },
        data: {
          type: 'tomorrow_wedding',
          weddingId,
          date: targetDate,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'push_channel',
            sound: 'default',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      successCount += response.successCount;
      failureCount += response.failureCount;
      await removeInvalidTokens(response.responses, tokenChunk);
    }

    await db.ref(`notificationLogs/tomorrowWedding/${targetDate}/${weddingId}`).set({
      sentAt: admin.database.ServerValue.TIMESTAMP,
      successCount,
      failureCount,
      title: weddingTitle(wedding),
    });

    console.log(`Yuborildi: success=${successCount}, failure=${failureCount}`);
  }
}

async function archivePastWeddings() {
  const db = admin.database();
  const today = process.env.TODAY_DATE || formatDateInTashkent(new Date());
  const snap = await db.ref('weddings').once('value');
  const weddings = snap.val() || {};
  const updates = {};
  const nowIso = new Date().toISOString();

  for (const [id, wedding] of Object.entries(weddings)) {
    if (!wedding || typeof wedding !== 'object') continue;
    const date = normalizeDate(wedding.date);
    if (date && date < today) {
      updates[`history/${id}`] = {
        ...wedding,
        date,
        status: 'archived',
        completedAt: nowIso,
        archivedAt: nowIso,
        updatedAt: Date.now(),
      };
      updates[`weddings/${id}`] = null;
    }
  }

  if (Object.keys(updates).length === 0) {
    console.log('Arxivga o‘tkaziladigan eski to‘y topilmadi.');
    return;
  }

  await db.ref().update(updates);
  console.log(`Arxivga o‘tkazildi: ${Object.keys(updates).length / 2} ta to‘y.`);
}

async function main() {
  const serviceAccount = readServiceAccount();
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL || DEFAULT_DATABASE_URL,
  });

  await archivePastWeddings();
  await sendTomorrowWeddingNotifications();
  console.log('GitHub Actions notification script tugadi.');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
