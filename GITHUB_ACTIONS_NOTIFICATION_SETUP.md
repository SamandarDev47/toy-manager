# Toy Manager — Blaze'siz bepul notification sozlash

Bu variantda Firebase Cloud Functions kerak emas. Notificationni GitHub Actions har kuni avtomatik yuboradi.

## Nima ishlaydi?

- Har kuni Toshkent vaqti bilan 09:00 da GitHub Actions ishga tushadi.
- `weddings` ichidan ertangi to‘ylarni tekshiradi.
- `userTokens` ichidagi FCM tokenlarga push notification yuboradi.
- Sanasi o‘tgan to‘ylarni avtomatik `history` arxiviga o‘tkazadi.
- Har bir to‘y uchun bir kunda faqat 1 marta notification yuboradi: `notificationLogs/tomorrowWedding/...`.

## 1-qadam. Projectni GitHub repositoryga push qiling

Project GitHub repositoryda bo‘lishi kerak. `.github/workflows/tomorrow_notifications.yml` faylini GitHub ko‘rishi uchun kod repositoryga push qilinadi.

## 2-qadam. Firebase Service Account JSON olish

1. Firebase Console oching.
2. Projectingizni tanlang: `toy-manager`.
3. **Project settings** ga kiring.
4. **Service accounts** tabiga o‘ting.
5. **Generate new private key** tugmasini bosing.
6. JSON fayl yuklanadi.

Muhim: bu JSON maxfiy. Uni hech kimga yubormang va GitHub code ichiga qo‘shmang.

## 3-qadam. GitHub Secret qo‘shish

GitHub repositoryda:

1. **Settings** → **Secrets and variables** → **Actions** ga kiring.
2. **New repository secret** bosing.
3. Name:

```text
FIREBASE_SERVICE_ACCOUNT
```

4. Value joyiga Firebase’dan yuklangan service account JSON ichidagi hamma kodni to‘liq paste qiling.
5. **Add secret** bosing.

## 4-qadam. Database URL secret qo‘shish

Yana bitta secret qo‘shing:

Name:

```text
FIREBASE_DATABASE_URL
```

Value:

```text
https://toy-manager-default-rtdb.firebaseio.com
```

## 5-qadam. Ishlashini qo‘lda test qilish

GitHub repositoryda:

1. **Actions** tabiga kiring.
2. **Tomorrow wedding notifications** workflowini tanlang.
3. **Run workflow** bosing.

Agar ertangi sanada to‘y bo‘lsa va app token saqlagan bo‘lsa, notification boradi.

## App token saqlashi uchun

Foydalanuvchi appga kamida bir marta kirishi kerak. Shunda app FCM tokenni `userTokens/{uid}` ichiga saqlaydi.

## Lokal test qilish

Kompyuterda test qilish uchun:

```bash
cd scripts
npm install
$env:FIREBASE_SERVICE_ACCOUNT = Get-Content "C:\path\service-account.json" -Raw
$env:FIREBASE_DATABASE_URL = "https://toy-manager-default-rtdb.firebaseio.com"
node send_tomorrow_notifications.js
```

PowerShell uchun yuqoridagi `$env:...` ishlaydi.

## Diqqat

- Bu usul Blaze talab qilmaydi.
- Yangi to‘y yaratilgan zahoti server push yuborish bu usulda real-time emas.
- Ertangi to‘y eslatmasi esa avtomatik ishlaydi.
- GitHub Actions cron vaqti ba’zan bir necha daqiqa kechikishi mumkin, bu normal.
