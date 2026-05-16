# ArtisanGo 🔧

A modern Flutter mobile application that connects customers with local artisans in Morocco. Built with Clean Architecture, Firebase, and Riverpod state management.

## 📱 Features

### Customer Features
- ✅ Multiple authentication methods (Email, Google, Phone OTP)
- ✅ Search artisans by category, city, and rating
- ✅ Browse artisan profiles with galleries and certifications
- ✅ Real-time booking system with date/time selection
- ✅ Real-time chat with artisans
- ✅ Secure payment integration (Cash, Card, Mobile Payment)
- ✅ Review and rating system
- ✅ Favorites management
- ✅ Push notifications

### Artisan Features
- ✅ Professional registration with ID verification
- ✅ Portfolio management with photo galleries
- ✅ Availability calendar
- ✅ Booking management (Accept/Reject/Complete)
- ✅ Earnings dashboard
- ✅ Customer reviews and ratings

### Admin Features
- ✅ Dashboard with analytics
- ✅ User and artisan management
- ✅ Artisan verification workflow
- ✅ Category and pricing management
- ✅ Reports and abuse management

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.10+
- Dart 3.0+
- Material Design 3

**State Management:**
- Riverpod (with code generation)

**Backend & Services:**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Analytics

**Architecture:**
- Clean Architecture
- MVVM Pattern

**Key Packages:**
- `go_router` - Routing and navigation
- `freezed` - Code generation for models
- `dio` - HTTP client
- `google_maps_flutter` - Maps integration
- `image_picker` & `image_cropper` - Media handling
- `flutter_local_notifications` - Local notifications
- `intl` - Localization (French, Arabic, English)

## 📋 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── firebase_config.dart
│   │   ├── app_config.dart
│   │   └── theme_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── firebase_collections.dart
│   │   └── error_messages.dart
│   ├── di/
│   │   └── service_locator.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── string_extensions.dart
│   │   ├── date_extensions.dart
│   │   └── widget_extensions.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── connectivity_service.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── logger_util.dart
│   │   └── dialog_utils.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_loader.dart
│       └── app_error_widget.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── notifiers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── artisan_discovery/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── artisan_profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── booking/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── payments/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── notifications/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── admin/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│   ├── models/
│   ├── widgets/
│   └── utils/
│
├── main.dart
└── app.dart

assets/
├── images/
├── icons/
├── animations/
└── fonts/

test/
├── features/
└── core/

firebase/
├── firestore.rules
├── storage.rules
└── functions/
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10 or higher
- Dart 3.0 or higher
- Firebase project created on Firebase Console
- XCode (for iOS)
- Android Studio (for Android)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/abdo-5432/artisango.git
cd artisango
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate code:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configure Firebase:**
   - Create a Firebase project at https://firebase.google.com
   - Add Android and iOS apps to your Firebase project
   - Download and place `google-services.json` in `android/app/`
   - Download and place `GoogleService-Info.plist` in `ios/Runner/`
   - Enable Authentication, Firestore, Storage, and Cloud Messaging

5. **Setup environment variables:**
```bash
cp .env.example .env
# Edit .env with your configuration values
```

6. **Run the app:**
```bash
flutter run
```

## 🔐 Firebase Setup Guide

### Authentication Methods

1. **Email/Password**
   - Enable in Firebase Console
   - Supports sign up, login, and password reset

2. **Google Sign-In**
   - Create OAuth 2.0 credentials in Google Cloud Console
   - Configure Android and iOS apps
   - Download and configure credentials

3. **Phone Authentication (OTP)**
   - Enable Phone Authentication in Firebase
   - Configure SASL Mechanisms

### Firestore Collections

See `firebase/firestore.rules` for complete schema and security rules.

**Collections:**
- `users` - Customer profiles
- `artisans` - Artisan profiles and details
- `categories` - Service categories
- `bookings` - Service bookings and history
- `messages` - Real-time chat messages
- `reviews` - Reviews and ratings
- `notifications` - User notifications
- `payments` - Payment records

### Security Rules

All security rules are defined in `firebase/firestore.rules`. Key rules:
- Users can only read/write their own documents
- Artisans can manage their profiles and bookings
- Admins have full access to all collections
- Messages are private between users
- Reviews can only be written after booking completion

## 📱 App Configuration

### Themes

The app supports Light and Dark modes with Material Design 3:

- **Primary Color:** #6C63FF (Purple)
- **Secondary Colors:** White, Light Gray
- **Font Family:** Poppins

### Languages

- French (fr)
- Arabic (ar)
- English (en)

Toggle language in Settings.

## 📝 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/features
```

### Run Integration Tests
```bash
flutter test --tags=integration
```

### Code Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 Sample Data

To populate your Firebase project with sample data, run:

```bash
dart run scripts/seed_firestore.dart
```

This will create:
- 5 sample customers
- 15 sample artisans across categories
- 10 sample bookings
- Categories for all trade types

## 🏗️ Building for Release

### Android

```bash
# Generate APK
flutter build apk --release

# Generate App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Archive and upload to App Store
flutter build ios --release
```

## 🚀 Deployment

### Google Play Store

1. Create a Google Play Developer account
2. Generate signing key
3. Configure signing in `android/app/build.gradle`
4. Build App Bundle: `flutter build appbundle --release`
5. Upload to Google Play Console

### Apple App Store

1. Create Apple Developer account
2. Create App ID and provisioning profiles
3. Configure signing in XCode
4. Build and archive in XCode
5. Upload to App Store Connect

## 🐛 Troubleshooting

### Firebase Connection Issues
- Verify internet connection
- Check Firebase project configuration
- Ensure correct google-services.json and GoogleService-Info.plist

### Build Errors
- Run `flutter clean`
- Delete `build/` and `pubspec.lock`
- Run `flutter pub get` and `flutter pub run build_runner build`

### State Management Issues
- Clear app cache
- Restart the dev server
- Rebuild with `flutter clean && flutter pub get`

## 📚 Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@artisango.ma or create an issue in the repository.

## 🙏 Acknowledgments

- Flutter and Dart teams
- Firebase community
- Riverpod maintainers
- All contributors

---

**Built with ❤️ for the Moroccan artisan community**
