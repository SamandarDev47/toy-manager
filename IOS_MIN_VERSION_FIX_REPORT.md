# iOS build fix

Fixed Codemagic/Xcode error where Firebase packages required iOS 15.0 while the app target supported iOS 13.0.

Changed files:
- `ios/Runner.xcodeproj/project.pbxproj` — `IPHONEOS_DEPLOYMENT_TARGET` changed from `13.0` to `15.0`.
- `ios/Flutter/AppFrameworkInfo.plist` — `MinimumOSVersion` changed from `13.0` to `15.0`.
- `ios/Podfile` — added/updated `platform :ios, '15.0'` for CocoaPods compatibility.
- `codemagic.yaml` — added a small cache-clean step for stale iOS pods before build.

Run locally or in Codemagic:

```bash
flutter clean
flutter pub get
flutter build ios --release --no-codesign
```

For a real IPA/TestFlight build, configure Apple signing in Codemagic.
