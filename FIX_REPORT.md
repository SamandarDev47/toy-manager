# To‘y Manager katta fix hisoboti

## Qilingan asosiy tuzatishlar

1. **Auth qo‘shildi**
   - `firebase_auth` dependency qo‘shildi.
   - `AuthGate`, `LoginPage`, `AuthService` qo‘shildi.
   - Ro‘yxatdan o‘tishda ism, familya, telefon, email va parol olinadi.
   - Profil ma’lumotlari `/users/{uid}` branchida saqlanadi.

2. **Profil / sozlanmalar page qo‘shildi**
   - Ism, familya, telefon tahrirlash.
   - Accountdan chiqish.
   - Asosiy jadvalni tozalashda tasdiqlash dialogi.
   - Firebase branchlar haqida eslatma.

3. **Chat bo‘limi qo‘shildi**
   - Guruh chat: `/chats/main/messages`.
   - Kim yozgani: ism, telefon, role bilan saqlanadi.
   - Reply, edit, delete funksiyalari.
   - O‘qildi/o‘qilmadi belgisi (`readBy`).
   - Typing indicator (`yozmoqda...`).

4. **Arxiv muammosi tuzatildi**
   - Eski loyiha sanani ba’zan `dd-MM-yyyy`, ba’zan ISO tarzda ishlatgani uchun arxiv ishlamay qolgan.
   - Endi yangi saqlangan to‘y sanasi `yyyy-MM-dd` formatida yoziladi.
   - Ilova ochilganda o‘tgan sanali to‘ylar avtomatik `history` branchiga ko‘chadi.
   - To‘y detail oynasida qo‘lda `Arxivga` tugmasi ham bor.
   - Cloud Function `archivePastWeddings` qo‘shildi.

5. **Firebase token xatosi tuzatildi**
   - Oldin token `weddings/userTokens` ichiga yozilgan.
   - Endi to‘g‘ri joy: `/userTokens/{uid}`.

6. **UI va performance yaxshilandi**
   - `MotionTabBar` o‘rniga Material 3 `NavigationBar` ishlatildi.
   - `IndexedStack` sahifalarni qayta-qayta qurib tashlamaydi.
   - Home UI soddaroq, tezroq va telefonda qulayroq qilindi.
   - Og‘ir blur/animatsiya asosiy ro‘yxatdan olib tashlandi.

## Firebase Console’da qilish kerak

1. Authentication → Sign-in method → **Email/Password** ni yoqing.
2. Realtime Database rules uchun `database.rules.json` ni deploy qiling.
3. Functions ishlashi uchun Firebase Blaze plan talab qilinishi mumkin.
4. Android uchun `android/app/google-services.json` fayli joyida ekanini tekshiring.

## Ishga tushirish

```bash
flutter clean
flutter pub get
flutter run
```

Agar eski bazadagi sanalar `dd-MM-yyyy` bo‘lsa, ilova ularni ham o‘qiydi. Yangi yozuvlar esa avtomatik `yyyy-MM-dd` bo‘ladi.
