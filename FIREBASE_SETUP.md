# Firebase Setup Guide

## Quick Fix for "No such module 'Firebase'" Error

The app is now configured to work **without Firebase** using mock authentication. However, to use real Firebase authentication, follow these steps:

## Option 1: Add Firebase SDK (Recommended)

### Step 1: Add Firebase Package in Xcode
1. Open your Xcode project
2. Go to **File → Add Package Dependencies...**
3. Enter URL: `https://github.com/firebase/firebase-ios-sdk.git`
4. Click **Add Package**
5. Select these products:
   - ✅ FirebaseAuth
   - ✅ FirebaseAnalytics (optional)
   - ✅ FirebaseCrashlytics (optional)

### Step 2: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Create a project**
3. Enter project name: `SubleaseFinder`
4. Follow the setup wizard

### Step 3: Add iOS App to Firebase
1. In Firebase Console, click **Add app** → **iOS**
2. Enter your Bundle ID (e.g., `com.yourname.subleaseFinder`)
3. Download `GoogleService-Info.plist`
4. Drag the file into your Xcode project (make sure "Copy items if needed" is checked)

### Step 4: Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Enable these sign-in methods:
   - ✅ Email/Password
   - ✅ Anonymous
   - ✅ Apple (optional)
   - ✅ Google (optional)

## Option 2: Continue Without Firebase (Current State)

The app is already configured to work without Firebase using mock authentication. You can:

- ✅ Browse listings
- ✅ Use the app as a guest
- ✅ Test all UI features
- ✅ Use mock authentication

## Testing the App

### With Firebase
- Real authentication with email/password
- Anonymous sign-in
- Token-based API authentication

### Without Firebase (Current)
- Mock authentication
- All features work with simulated data
- Perfect for development and testing

## Next Steps

1. **For Development**: Continue without Firebase for now
2. **For Production**: Add Firebase SDK and configure real authentication
3. **For Testing**: The mock services provide full functionality

## Troubleshooting

### If you still get "No such module 'Firebase'"
- Make sure you added the Firebase package in Xcode
- Clean build folder (Product → Clean Build Folder)
- Restart Xcode

### If Firebase doesn't work
- Check that `GoogleService-Info.plist` is in your project
- Verify Bundle ID matches Firebase project
- Check Firebase Console for any setup errors

## Current Status

✅ **App works without Firebase**  
✅ **Mock authentication implemented**  
✅ **All features functional**  
🔄 **Ready for Firebase integration when needed**
