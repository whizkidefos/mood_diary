# Fix Instructions for Mood Diary App

Follow these steps to resolve the dependency and permission issues in the Mood Diary app.

## Step 1: Fix Windows File Permission Errors

1. Run the batch file as Administrator:
   - Right-click on `fix_flutter_permissions.bat` in the project root
   - Select "Run as administrator"
   - Wait for the script to complete

## Step 2: Update Dependencies

After the batch file completes:

1. Open a command prompt or PowerShell window as Administrator
2. Navigate to your project directory:
   ```
   cd c:\Users\efosa\OneDrive\Desktop\projects\mobileapps\mood_diary
   ```
3. Run Flutter pub get:
   ```
   flutter pub get
   ```

## Step 3: Configure Firebase

1. Make sure your `.env` file is properly configured with your Firebase credentials
2. In your Firebase Console:
   - Navigate to Firestore Database > Rules
   - Replace the rules with the content from `firestore.rules`
   - Click "Publish"

## Step 4: Run the App

1. Run the app on your preferred platform:
   ```
   flutter run -d windows
   ```
   or
   ```
   flutter run -d chrome
   ```

## Troubleshooting

If you still encounter issues:

1. **Dependency Conflicts**:
   - Try running `flutter pub upgrade --major-versions` to update all dependencies
   - If specific packages cause issues, you may need to adjust their versions in `pubspec.yaml`

2. **Persistent Permission Errors**:
   - Close all instances of your IDE and Flutter processes
   - Delete the `windows\flutter\ephemeral` directory manually
   - Restart your computer and try again

3. **Firebase Connection Issues**:
   - Verify your Firebase project is properly set up
   - Check that your `.env` file contains the correct configuration values
   - Ensure your Firebase project has Firestore enabled and rules published
