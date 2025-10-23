# Google va Apple Auth sozlash

## 1) Firebase Console
Authentication → Sign-in method ichida quyidagilar Enabled bo‘lsin:
- Email/Password
- Google
- Apple

## 2) Android Google Sign-In
Firebase Console → Project settings → Your apps → Android app ichida SHA-1 va SHA-256 qo‘shing.

Terminalda project papkasida:

```bash
cd android
./gradlew signingReport
```

Windows PowerShell’da:

```powershell
cd android
.\gradlew signingReport
```

`debug` variantidagi SHA-1 va SHA-256 ni Firebase Console’ga qo‘shing. Keyin yangilangan `google-services.json` ni yuklab olib `android/app/google-services.json` ustiga tashlang.

## 3) Apple Sign-In
Apple login faqat iOS/macOS qurilmada to‘liq ishlaydi. Firebase Console’da Apple provider yoqilgan bo‘lishi kerak. iOS release uchun Apple Developer’da Sign in with Apple capability ham yoqiladi.

## 4) Ishga tushirish

```bash
flutter clean
flutter pub get
flutter run
```

## 5) Profil ma’lumotlari
Google/Apple orqali kirganda email, displayName va rasm avtomatik `users/{uid}` ichiga saqlanadi. Telefon raqamni foydalanuvchi Profil/Sozlanmalar sahifasida qo‘shadi yoki o‘zgartiradi.
