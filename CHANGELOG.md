# Changelog

## 2025-09-10: Additional Fixes (Update 2)

### Bug Fixes
- Replaced discontinued `translator` package with `translator_plus` ^1.0.1
- Created batch file `fix_flutter_permissions.bat` to resolve Windows file permission errors in Flutter ephemeral directories

## 2025-09-10: Additional Fixes (Update 1)

### Bug Fixes
- Reverted `js` package from ^0.7.1 to ^0.6.7 to fix JavaScript error with '_scriptUrls' identifier
- Added Firestore security rules to fix permissions error
- Created `firestore.rules` file with development and production rule templates

## 2025-09-10: Package Updates and Compatibility Fixes

### Package Updates
- Updated Firebase packages:
  - `firebase_core`: ^2.24.2 → ^2.27.1
  - `firebase_auth`: ^4.15.3 → ^4.17.9
  - `cloud_firestore`: ^4.13.6 → ^4.15.9
  - `firebase_storage`: ^11.5.6 → ^11.6.10
  - `firebase_messaging`: ^14.7.9 → ^14.7.20
- Updated UI and utility packages:
  - `provider`: ^6.1.1 → ^6.1.2
  - `shared_preferences`: ^2.2.2 → ^2.2.3
  - `path_provider`: ^2.1.1 → ^2.1.2
  - `js`: ^0.6.7 → ^0.7.1
- Updated media handling packages:
  - `flutter_local_notifications`: ^14.0.0 → ^16.3.2
  - `speech_to_text`: ^5.4.0 → ^6.6.0
  - `record`: ^5.0.0 → ^5.0.4
  - `image_picker`: ^0.8.5+3 → ^1.0.7
  - `just_audio`: ^0.9.0 → ^0.9.36

### Code Changes

#### 1. Fixed image_picker compatibility issues
- Updated the `_pickImages()` method in `chat_input.dart` to explicitly type the returned images as `List<XFile>` for compatibility with image_picker 1.0.x.

#### 2. Fixed flutter_local_notifications compatibility issues
- Added permission request for Android notifications in `notification_service.dart` using the new API:
  ```dart
  await _notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  ```

#### 3. Fixed Firebase Auth deprecated methods
- Updated the deprecated `updateProfile` method in `firebase_service.dart` to use the new separate methods:
  ```dart
  // Old code
  await user.updateProfile(
    displayName: displayName ?? user.displayName,
    photoURL: photoURL ?? user.photoURL,
  );
  
  // New code
  if (displayName != null) {
    await user.updateDisplayName(displayName);
  }
  
  if (photoURL != null) {
    await user.updatePhotoURL(photoURL);
  }
  ```

#### 4. Fixed duplicate AudioPlayer instance in VoiceMessagePlayer
- Removed the redundant `_audioPlayer` instance in `voice_message_player.dart` that was causing potential conflicts with the existing `_player` instance.

### Configuration
- Created `.env.example` template file with placeholder values for Firebase configuration
- Added instructions for setting up the `.env` file in the RUNNING_INSTRUCTIONS.md

### Documentation
- Updated README.md with comprehensive setup and deployment instructions
- Created RUNNING_INSTRUCTIONS.md with detailed steps for running the app after updates
- Created this CHANGELOG.md to document all changes made to the codebase
