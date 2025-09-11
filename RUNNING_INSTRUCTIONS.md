# Running the Mood Diary App

This document provides step-by-step instructions for setting up and running the Mood Diary app after the package updates.

## Prerequisites

- Flutter SDK 3.24.5 or higher
- Dart SDK 3.5.4 or higher
- Firebase project set up

## Setup Steps

### 1. Configure Firebase

1. Create a `.env` file in the root directory of the project by copying the `.env.example` file:
   ```
   cp .env.example .env
   ```

2. Fill in your Firebase configuration values in the `.env` file:
   ```
   # Firebase Configuration
   # Android
   FIREBASE_ANDROID_API_KEY=your_android_api_key
   FIREBASE_ANDROID_APP_ID=your_android_app_id
   
   # iOS
   FIREBASE_IOS_API_KEY=your_ios_api_key
   FIREBASE_IOS_APP_ID=your_ios_app_id
   FIREBASE_IOS_BUNDLE_ID=com.example.moodDiary
   
   # Common
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
   ```

3. Download and place the Firebase configuration files:
   - For Android: Place `google-services.json` in the `android/app/` directory
   - For iOS: Place `GoogleService-Info.plist` in the `ios/Runner/` directory

4. Configure Firestore Security Rules:
   - In your Firebase Console, navigate to Firestore Database > Rules
   - For development and testing, you can use the permissive rules in the `firestore.rules` file:
     ```
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if true;
         }
       }
     }
     ```
   - **Important**: Before deploying to production, update these rules to be more restrictive

### 2. Install Dependencies

Run the following command to install all the updated dependencies:

```
flutter pub get
```

### 3. Run the App

Choose one of the following commands based on your target platform:

- **Android**:
  ```
  flutter run -d android
  ```

- **iOS**:
  ```
  flutter run -d ios
  ```

- **Web**:
  ```
  flutter run -d chrome
  ```

- **Windows**:
  ```
  flutter run -d windows
  ```

- **macOS**:
  ```
  flutter run -d macos
  ```

## Troubleshooting

### Common Issues

1. **Firebase Configuration Issues**:
   - Ensure all Firebase configuration values in the `.env` file are correct
   - Verify that the Firebase configuration files are in the correct locations

2. **Package Compatibility Issues**:
   - If you encounter any package compatibility issues, run `flutter clean` and then `flutter pub get` again

3. **Build Errors**:
   - For Android: Check the `android/app/build.gradle` file for any configuration issues
   - For iOS: Open the project in Xcode and resolve any configuration issues

## Recent Updates

The following packages have been updated to their latest versions:

- Firebase packages (core, auth, firestore, storage, messaging)
- flutter_local_notifications (14.0.0 → 16.3.2)
- image_picker (0.8.5+3 → 1.0.7)
- speech_to_text (5.4.0 → 6.6.0)
- just_audio (0.9.0 → 0.9.36)
- record (5.0.0 → 5.0.4)
- js (0.6.7 → 0.7.1)

Code changes have been made to ensure compatibility with these updated packages.
