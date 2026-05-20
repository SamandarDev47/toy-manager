# Toy Manager katta fix

## Tuzatildi
- Hamma asosiy page bir xil `AppTheme + AppShell` dizayniga o'tkazildi.
- Light/Dark mode qo'shildi. Profil sahifasidan switch orqali almashtiriladi.
- Chatda boshqa foydalanuvchi yozayotganida pastda animatsiyali `typing...` chiqadi.
- Chat xabarlari faqat Chat tab ochilganda `readBy` bo'ladi.
- Chat icon ustidagi unread badge saqlandi.
- Arxivdagi to'ylarni endi o'chirish mumkin.
- Profilga `Lavozim` maydoni qo'shildi; bo'sh qoldirilsa `user` saqlanadi.
- UI aralash ranglari to'g'irlandi: oq fon/oq text muammosi bartaraf qilindi.
- Ilova hajmini kamaytirish uchun ishlatilmayotgan og'ir dependencylar pubspecdan olindi:
  - cloud_firestore
  - fl_chart
  - animations
  - lottie
  - motion_tab_bar_v2
  - google_nav_bar
  - capped_progress_indicator
  - internet_connection_checker_plus

## Muhim
Terminalda yangi zipni qo'ygandan keyin:

```bash
flutter clean
flutter pub get
flutter run
```

Agar `WidgetStateProperty` xato bersa, Flutter SDK eski. Flutter upgrade qiling yoki `WidgetStateProperty` -> `MaterialStateProperty` almashtiriladi.
