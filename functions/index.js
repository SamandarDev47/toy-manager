const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

function tashkentDate(offsetDays = 0) {
  const now = new Date();
  const utc = now.getTime() + now.getTimezoneOffset() * 60000;
  const tashkent = new Date(utc + 5 * 60 * 60000);
  tashkent.setDate(tashkent.getDate() + offsetDays);
  return tashkent.toISOString().slice(0, 10);
}

exports.sendTomorrowNotifications = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('Asia/Tashkent')
  .onRun(async () => {
    const targetDate = tashkentDate(1);
    const weddingsSnap = await admin.database().ref('weddings').once('value');
    const weddings = weddingsSnap.val() || {};
    const tokensSnap = await admin.database().ref('userTokens').once('value');
    const tokens = tokensSnap.val() || {};
    const tokenList = Object.values(tokens).map((v) => v.token).filter(Boolean);
    if (tokenList.length === 0) return null;

    for (const id of Object.keys(weddings)) {
      const w = weddings[id];
      if (w.date === targetDate) {
        await admin.messaging().sendEachForMulticast({
          tokens: tokenList,
          notification: {
            title: 'Ertaga to‘y bor 💍',
            body: `${w.location || 'To‘y'} • ${w.timeOfDay || ''}`,
          },
          data: { weddingId: id, type: 'tomorrow_wedding' },
        });
      }
    }
    return null;
  });

exports.archivePastWeddings = functions.pubsub
  .schedule('5 0 * * *')
  .timeZone('Asia/Tashkent')
  .onRun(async () => {
    const today = tashkentDate(0);
    const ref = admin.database().ref('weddings');
    const snap = await ref.once('value');
    const weddings = snap.val() || {};
    const updates = {};
    const nowIso = new Date().toISOString();

    Object.entries(weddings).forEach(([id, w]) => {
      if (w.date && w.date < today) {
        updates[`history/${id}`] = {
          ...w,
          status: 'archived',
          completedAt: nowIso,
          archivedAt: nowIso,
          updatedAt: Date.now(),
        };
        updates[`weddings/${id}`] = null;
      }
    });

    if (Object.keys(updates).length > 0) {
      await admin.database().ref().update(updates);
    }
    return null;
  });
