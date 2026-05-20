# Chat va notification yangilanishlari

## Chatda qo‘shilganlar

1. Xabar ustiga bosib turilganda menyuda `Kimlar ko‘rgan?` chiqadi.
2. `Kimlar ko‘rgan?` oynasida xabarni o‘qigan foydalanuvchilar ismi, roli va ko‘rgan vaqti ko‘rinadi.
3. Ikki tick faqat foydalanuvchi Chat sahifasiga kirganda bosiladi. App ichida boshqa sahifada yurganda avtomatik read qilmaydi.
4. Chat iconi ustida unread badge qo‘shildi: 1, 2, 3... ko‘rinadi.
5. Xabar yuborilganda `readBy` bilan birga `readAt` ham saqlanadi.

## Notificationlarda qo‘shilganlar

1. Yangi to‘y yaratilganda barcha tokenlarga push notification yuboriladi.
2. Har kuni soat 09:00 da ertangi to‘ylarni tekshiradi.
3. Ertaga to‘y bo‘lsa: `Ertaga kunduzi/kechqurun to‘y bor. Ilovaga bir qarang.` mazmunida notification yuboradi.
4. Eski token yangilansa, avtomatik `userTokens/{uid}` ichiga qayta saqlanadi.

## Firebase deploy qilish

Terminalda project papkadan:

```bash
firebase login
firebase init functions
firebase deploy --only functions
firebase deploy --only database
```

Agar functions allaqachon bor bo‘lsa, faqat:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Scheduled notification ishlashi uchun Firebase projectda billing/Blaze plan talab qilinishi mumkin, chunki scheduled functions Cloud Scheduler orqali ishlaydi.
