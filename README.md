# Mood Diary Interactive

A comprehensive Flutter application for mood tracking, journaling, and mental wellness activities with social features.

## Features

- **Mood Tracking**: Log your daily moods with notes and gratitude entries
- **Daily Activity Tracking**: Monitor water intake, steps, sleep, and more
- **Interactive Activities**: Breathing exercises, meditation, art therapy, and games
- **Journal**: Guided journaling with prompts
- **Social Features**: Share stories and posts with friends
- **Achievements**: Earn achievements for consistent app usage

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android, iOS, Web, and/or desktop apps to your Firebase project
3. Download the configuration files:
   - For Android: `google-services.json` (place in `android/app/`)
   - For iOS: `GoogleService-Info.plist` (place in `ios/Runner/`)
   - For Web: Add the Firebase SDK to `web/index.html`

### Environment Configuration

1. Copy the `.env.example` file to `.env`:
   ```
   cp .env.example .env
   ```

2. Update the `.env` file with your Firebase configuration values

### Firebase Services Setup

1. Enable the following Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
   - Messaging (for notifications)

2. Set up Firestore security rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### Running the App

1. Install dependencies:
   ```
   flutter pub get
   ```

2. Run the app:
   ```
   flutter run
   ```

## Deployment

### Android

1. Update the `android/app/build.gradle` file with your app details
2. Generate a signed APK/App Bundle:
   ```
   flutter build appbundle
   ```
3. Upload to Google Play Console

### iOS

1. Update the iOS app settings in Xcode
2. Build the iOS release:
   ```
   flutter build ios
   ```
3. Upload to App Store Connect using Xcode

### Web

1. Build the web release:
   ```
   flutter build web
   ```
2. Deploy to Firebase Hosting:
   ```
   firebase deploy --only hosting
   ```

## Project Structure

- `lib/models/`: Data models
- `lib/screens/`: UI screens
- `lib/services/`: Business logic and Firebase interactions
- `lib/widgets/`: Reusable UI components
- `lib/coordinators/`: Manages interactions between different parts of the app

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
