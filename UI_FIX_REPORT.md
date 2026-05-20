# UI fix report

Bu versiyada UI bir xil professional dizaynga keltirildi.

## O'zgargan asosiy joylar

- `lib/theme/app_theme.dart` to'liq yangilandi: ranglar, inputlar, buttonlar, cardlar, dialoglar, bottom navigation bir xil stylega keltirildi.
- `lib/widgets/app_shell.dart` qo'shildi: barcha page'larda bir xil gradient background, hero panel, card va empty state ishlatiladi.
- `lib/pages/add_page.dart` qayta yozildi: oq fon/oq text muammosi tuzatildi, dropdownlar va tanlash chip'lari zamonaviy qilindi, og'ir blur/animatsiya olib tashlandi.
- `lib/pages/stats_page.dart` qayta yozildi: qotadigan animatsiya olib tashlandi, zamonaviy statistik cardlar qo'shildi.
- `lib/pages/history_page.dart` qayta yozildi: arxiv ekrani asosiy dizaynga moslashtirildi.
- `lib/pages/home_page.dart` background, empty state va cardlar umumiy dizaynga moslashtirildi.
- `lib/pages/chat/chat_page.dart` background va reply panel dizayni moslashtirildi.
- `lib/pages/profile/profile_settings_page.dart` umumiy backgroundga o'tkazildi.
- `lib/pages/auth/login_page.dart` auth sahifasi umumiy backgroundga o'tkazildi.
- `lib/widgets/main_navbar.dart` zamonaviy floating bottom navigation qilindi.

## Ishga tushirish

```bash
flutter clean
flutter pub get
flutter run
```

Agar white text/white background yana ko'rinsa, eski build cache qolgan bo'lishi mumkin. Avval `flutter clean` qiling.
