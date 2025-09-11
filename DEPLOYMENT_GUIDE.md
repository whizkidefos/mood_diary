# Deployment Guide for Mood Diary App

This guide outlines the steps to deploy the Mood Diary app to various platforms after completing the package updates and compatibility fixes.

## Prerequisites

- Completed all the steps in the RUNNING_INSTRUCTIONS.md
- Verified that the app runs correctly in development mode
- Firebase project fully configured with required services

## Deployment Steps by Platform

### Android Deployment

#### 1. Configure App Signing

1. Create a keystore file if you don't have one:
   ```
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create/update `android/key.properties` file:
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>/upload-keystore.jks
   ```

3. Configure signing in `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

#### 2. Build the App Bundle

```
flutter build appbundle
```

#### 3. Upload to Google Play Console

1. Log in to the [Google Play Console](https://play.google.com/console)
2. Create a new app or select your existing app
3. Navigate to "Production" > "Create new release"
4. Upload the app bundle from `build/app/outputs/bundle/release/app-release.aab`
5. Complete the store listing, content rating, and pricing details
6. Submit for review

### iOS Deployment

#### 1. Configure Xcode Project

1. Open the iOS project in Xcode:
   ```
   open ios/Runner.xcworkspace
   ```

2. Update the Bundle Identifier, Version, and Build Number
3. Configure signing certificates and provisioning profiles

#### 2. Build the iOS Release

```
flutter build ios
```

#### 3. Upload to App Store Connect

1. In Xcode, select "Product" > "Archive"
2. When the archive is complete, click "Distribute App"
3. Select "App Store Connect" and follow the prompts
4. Complete the App Store listing, screenshots, and metadata
5. Submit for review

### Web Deployment

#### 1. Build the Web Release

```
flutter build web
```

#### 2. Deploy to Firebase Hosting

1. Install Firebase CLI if not already installed:
   ```
   npm install -g firebase-tools
   ```

2. Initialize Firebase Hosting:
   ```
   firebase login
   firebase init hosting
   ```

3. Deploy to Firebase Hosting:
   ```
   firebase deploy --only hosting
   ```

### Windows Deployment

#### 1. Build the Windows Release

```
flutter build windows
```

#### 2. Create an Installer

1. Use a tool like Inno Setup to create an installer for your Windows app
2. Package the contents of `build/windows/runner/Release/` into the installer

### macOS Deployment

#### 1. Configure macOS Project

1. Update the bundle identifier and signing information in Xcode
2. Enable the necessary entitlements for your app

#### 2. Build the macOS Release

```
flutter build macos
```

#### 3. Create a DMG or PKG Installer

1. Use a tool like create-dmg or pkgbuild to create an installer
2. Package the contents of `build/macos/Build/Products/Release/`

## Post-Deployment Tasks

### 1. Monitor Analytics and Crash Reports

1. Set up Firebase Analytics to track user engagement
2. Configure Firebase Crashlytics to monitor app stability
3. Create dashboards to visualize key metrics

### 2. Implement Continuous Integration/Continuous Deployment (CI/CD)

1. Set up GitHub Actions or another CI/CD service
2. Automate testing and deployment processes
3. Configure automatic version bumping

### 3. Plan for Updates

1. Establish a regular update schedule
2. Prioritize user feedback for future features
3. Continue monitoring package updates for security and performance improvements

## Security Considerations

1. Ensure Firebase Security Rules are properly configured
2. Implement proper authentication and authorization
3. Secure sensitive data with encryption
4. Regularly audit and update security measures

## Compliance

1. Ensure the app complies with relevant privacy laws (GDPR, CCPA, etc.)
2. Include necessary privacy policies and terms of service
3. Implement data deletion mechanisms for user requests
