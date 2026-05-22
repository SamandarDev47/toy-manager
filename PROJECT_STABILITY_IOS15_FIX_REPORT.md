# Project stability + iOS 15 fix report

Qilingan katta fixlar:

1. iOS Firebase build xatosi uchun iOS minimum target to'liq 15.0 qilindi:
   - ios/Podfile
   - ios/Runner.xcodeproj/project.pbxproj
   - ios/Flutter/AppFrameworkInfo.plist
   - ios/Flutter/Debug.xcconfig
   - ios/Flutter/Release.xcconfig
   - codemagic.yaml ichida builddan oldin majburiy tekshiruv/fix scriptlari

2. Codemagic build script tozalandi:
   - Flutter clean
   - iOS Pods/Podfile.lock/.symlinks tozalash
   - DerivedData tozalash
   - pod install --repo-update
   - flutter build ios --release --no-codesign

3. Dart/Flutter project stability:
   - pubspec SDK beta constraint stable Flutter bilan moslashtirildi: >=3.6.0 <4.0.0
   - flutter_launcher_icons konfiguratsiyasi to'g'ri nomga o'tkazildi
   - "internet cheker" papkasi "internet_checker" qilib to'g'ri nomlandi

4. UI/logic xatolari:
   - AppShell/AppCard dark-light mode bilan moslashtirildi
   - Login page dark-light background/card ranglari moslashtirildi
   - Bottom Navigation dark-light mode bilan moslashtirildi
   - Chat tab faqat ochilganda active bo'ladi; IndexedStack ichida turgani uchun boshqa tabda read tick bosib yubormaydi
   - Chat icon unread badge saqlandi

5. Zip yengillashtirildi:
   - .git, build cache, android/.gradle, functions/node_modules kabi og'ir/generated papkalar chiqarib tashlanadi

Ishga tushirish:
flutter clean
flutter pub get
flutter run

Codemagic uchun:
GitHub'ga shu versiyani push qiling, Codemagic'da to'g'ri branch tanlanganini tekshiring va buildni Clean cache bilan qayta boshlang.
