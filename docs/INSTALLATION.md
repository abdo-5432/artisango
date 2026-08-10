# ArtisanGo — Installation Guide

This guide explains how to install and run ArtisanGo locally for development and testing.

ArtisanGo is a Flutter mobile application that connects customers with local artisans in Morocco. The application uses Firebase for authentication and cloud data, and Cloudinary for image storage.

## 1. Prerequisites

Before starting, make sure you have the following installed:

- Flutter SDK 3.0 or higher
- Dart SDK included with Flutter
- Android Studio
- Android SDK
- Git
- A physical Android device or an Android emulator

### Check Flutter installation

```bash
flutter --version
```

Check the development environment:

```bash
flutter doctor
```

Resolve any required issues reported by `flutter doctor` before continuing.

### Check Git installation

```bash
git --version
```

## 2. Download the Project

Clone the repository from GitHub:

```bash
git clone https://github.com/abdo-5432/artisango.git
```

Enter the project directory:

```bash
cd artisango
```

## 3. Install Dependencies

Install the Flutter dependencies:

```bash
flutter pub get
```

If generated code is required by the project, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 4. Firebase Configuration

ArtisanGo uses Firebase for authentication and cloud data.

Create a Firebase project:

https://console.firebase.google.com/

### Android configuration

Add an Android application to your Firebase project.

Download the Firebase configuration file:

```text
google-services.json
```

Place it in:

```text
android/app/google-services.json
```

### Authentication

In Firebase Console:

1. Open the project.
2. Open Authentication.
3. Open Sign-in method.
4. Enable Email/Password authentication.

### Cloud Firestore

Create a Firestore database from the Firebase Console.

The application uses Firestore for data such as:

- Users
- Services
- Reviews
- Favorites

Make sure the required Firestore configuration and rules are correctly configured for your environment.

## 5. Cloudinary Configuration

ArtisanGo uses Cloudinary to store uploaded images.

Create an account:

https://cloudinary.com/

Create the required upload configuration.

Update the Cloudinary configuration used by the application with your own values.

Do not publish private API secrets, passwords, or credentials in the repository.

## 6. Check Available Devices

Before running the application, check whether Flutter detects an Android device:

```bash
flutter devices
```

You should see either:

- A connected Android phone
- An Android emulator

## 7. Run the Application

Once a device is available, run:

```bash
flutter run
```

Flutter will build the application and launch it on the selected device.

## 8. Run on a Physical Android Phone

### Enable Developer Options

On your Android phone:

1. Open Settings.
2. Open About Phone.
3. Find Build Number.
4. Tap Build Number several times until Developer Options are enabled.

### Enable USB Debugging

Open:

```text
Settings → Developer Options
```

Enable:

```text
USB Debugging
```

### Connect the Phone

Connect the phone to the computer using a USB cable.

If Android asks you to authorize USB debugging, accept it.

### Verify the Device

Run:

```bash
flutter devices
```

Your phone should appear in the list.

### Launch ArtisanGo

Run:

```bash
flutter run
```

The application should be built and launched on the phone.

## 9. Run on an Android Emulator

Open Android Studio.

Go to:

```text
Device Manager
```

Create an Android Virtual Device if you do not already have one.

Start the emulator.

Then run:

```bash
flutter devices
```

Verify that the emulator appears.

Launch the application:

```bash
flutter run
```

## 10. Select a Specific Device

If multiple devices are connected, list them:

```bash
flutter devices
```

Then run the application using the desired device ID:

```bash
flutter run -d DEVICE_ID
```

Replace `DEVICE_ID` with the ID displayed by `flutter devices`.

## 11. Build a Release APK

To create a release APK:

```bash
flutter build apk --release
```

After a successful build, the APK is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

You can transfer this APK to an Android phone and install it for testing.

## 12. Run Tests

Run the project's tests with:

```bash
flutter test
```

## 13. Useful Flutter Commands

Check Flutter version:

```bash
flutter --version
```

Check the development environment:

```bash
flutter doctor
```

List connected devices:

```bash
flutter devices
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

Clean the project:

```bash
flutter clean
```

Reinstall dependencies:

```bash
flutter pub get
```

Build a release APK:

```bash
flutter build apk --release
```

## 14. Troubleshooting

### Flutter command not found

If Flutter is not recognized by the terminal, make sure Flutter is installed and its `bin` directory has been added to the system PATH.

Check the installation:

```bash
flutter --version
```

Then:

```bash
flutter doctor
```

### No Android device detected

Run:

```bash
flutter devices
```

If no device appears:

- Check the USB connection.
- Make sure USB debugging is enabled.
- Accept the USB debugging authorization on the phone.
- Make sure the Android emulator is running.
- Check the Android SDK configuration in Android Studio.

### Application does not start

Try cleaning the project:

```bash
flutter clean
```

Then reinstall the dependencies:

```bash
flutter pub get
```

Finally run:

```bash
flutter run
```

### Firebase connection problems

Check that:

- The Firebase project has been created.
- The Android application has been added to Firebase.
- `google-services.json` is in the correct location.
- Firebase Authentication is enabled.
- Firestore has been created.
- The Firebase configuration matches the application.

### Images are not displayed

Check the Cloudinary configuration.

Make sure the required Cloudinary values are correctly configured and that the upload configuration allows the application to upload images.

## 15. Project Structure

The main Flutter source code is located in:

```text
lib/
├── screens/
├── widgets/
├── services/
├── models/
├── translations/
└── main.dart
```

Other important directories include:

```text
assets/
android/
ios/
test/
docs/
screenshots/
```

## 16. Screenshots

Application screenshots are available in:

```text
screenshots/
```

They are also displayed in the main project README.

## 17. Documentation

Project overview:

[README.md](../README.md)

Installation guide:

[INSTALLATION.md](INSTALLATION.md)

## 18. Security Notes

Do not commit sensitive information to GitHub.

This includes:

- Passwords
- Private API keys
- Private credentials
- Production secrets
- Private configuration files

Use local configuration or environment variables when sensitive values are required.

## 19. Quick Start

For an already configured development environment:

```bash
git clone https://github.com/abdo-5432/artisango.git
cd artisango
flutter pub get
flutter devices
flutter run
```

If Firebase and Cloudinary are already configured, the application can be launched on the selected Android device.

## 20. Project Information

**Project:** ArtisanGo

**Platform:** Android

**Framework:** Flutter

**Language:** Dart

**Backend:** Firebase

**Image Storage:** Cloudinary

**Repository:**

https://github.com/abdo-5432/artisango