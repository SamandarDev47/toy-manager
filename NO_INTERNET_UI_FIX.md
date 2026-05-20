# No Internet UI Fix

Qilingan o'zgarishlar:

- Eski tepada chiqadigan qizil banner olib tashlandi.
- Offline holatda to'liq premium `NoInternetView` sahifa chiqadi.
- Dark/Light mode bilan mos ishlaydi.
- Lottie animation `assets/lottie/no_internet.json` orqali ulanadi.
- `pubspec.yaml` ichiga `lottie` dependency va `assets/lottie/`, `assets/icon/` asset pathlari qo'shildi.
- `ConnectionChecker` stateful qilindi: internet holatini initial check qiladi va stream orqali kuzatadi.

Ishga tushirish:

```powershell
flutter clean
flutter pub get
flutter run
```
