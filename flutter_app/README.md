# EGF Reader - Flutter App

A Flutter WebView-based application for reading EGF (Educational Game Format) files.

## Overview

This Flutter app wraps the existing web-based EGF Reader in a native WebView, providing:
- Native file picker for selecting .egf files
- Local storage via IndexedDB (persisted in WebView)
- Full offline support
- Native performance and integration

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── screens/
│   │   └── home_screen.dart   # Main WebView screen
│   └── services/
│       └── web_server.dart    # Local HTTP server for web assets
├── assets/
│   └── web/                   # Web application files (copied from parent)
├── android/                   # Android-specific configuration
├── ios/                       # iOS-specific configuration
└── pubspec.yaml              # Flutter dependencies
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

### 1. Copy Web Assets

Before building, copy the web application files to the assets folder:

```bash
cd flutter_app
mkdir -p assets/web
cp ../index.html assets/web/
cp ../app.js assets/web/
cp ../style.css assets/web/
cp ../i18n.js assets/web/
cp ../jszip.min.js assets/web/
```

Or on Windows:
```cmd
cd flutter_app
mkdir assets\web
copy ..\index.html assets\web\
copy ..\app.js assets\web\
copy ..\style.css assets\web\
copy ..\i18n.js assets\web\
copy ..\jszip.min.js assets\web\
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

**Debug mode:**
```bash
flutter run
```

**Release mode:**
```bash
flutter run --release
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

The AAB will be at: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires macOS and Xcode)

```bash
flutter build ios --release
```

Then archive and submit through Xcode.

## Configuration

### Android

- **Package ID:** `org.egfformat.reader`
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 34 (Android 14)

### iOS

- **Bundle ID:** Configure in Xcode
- **Min iOS Version:** 12.0

## Features

- 📚 **Bookshelf/Library** - Save and organize your EGF games
- 🎮 **Full Game Support** - Play all EGF 1.0 and 1.1 games
- 🌍 **Multi-language** - Support for 9 languages
- 🌙 **Dark/Light Theme** - Automatic or manual theme switching
- 📱 **Responsive Design** - Works on phones and tablets
- 💾 **Offline Support** - Games are stored locally

## Troubleshooting

### WebView not loading

1. Ensure web assets are copied to `assets/web/`
2. Check that `pubspec.yaml` includes the assets
3. Run `flutter clean && flutter pub get`

### File picker not working

1. Check Android permissions in `AndroidManifest.xml`
2. For Android 13+, ensure media permissions are requested
3. For iOS, check Info.plist permissions

### Build failures

1. Update Flutter: `flutter upgrade`
2. Clean build: `flutter clean`
3. Update dependencies: `flutter pub upgrade`

## License

MIT License - See LICENSE.md in the parent directory.
