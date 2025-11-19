# 🔥 Firestore Setup Guide

This guide explains how to configure Firestore in the Firebase console to connect your iOS application to the cloud database.

## 📋 Prerequisites

- ✅ Firebase is already configured in your project (see `FIREBASE_XCODE_STEPS.md`)
- ✅ The `GoogleService-Info.plist` file is present in your project
- ✅ The Firebase package is installed in Xcode

## 🎯 Step 1: Create the Firestore Database

### In the Firebase console:

1. **Open the Firebase console**: https://console.firebase.google.com
2. **Select your project**: "Cubstart"
3. **In the left menu**, click on **"Firestore Database"**
4. **Click on "Create database"** (or "Créer une base de données")

### Database configuration:

1. **Choose the mode**:
   - ✅ **Production mode** (recommended for a real app)
   - ⚠️ **Test mode** (for quick testing - expires after 30 days)

2. **Select the location**:
   - Choose the region closest to your users
   - Example: `europe-west` for Europe

3. **Click "Activate"**

## 🎯 Step 2: Configure Security Rules

### Default rules (Test mode):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 18);
    }
  }
}
```

⚠️ **These rules expire after 30 days and allow anyone to read/write!**

### Recommended rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Tasks collection
    match /tasks/{taskId} {
      // Allow read and write to all authenticated users
      // For now, we allow all (you can add authentication later)
      allow read, write: if true;
      
      // Or with authentication:
      // allow read, write: if request.auth != null;
    }
  }
}
```

### How to modify rules:

1. In Firestore Database, click on the **"Rules"** tab
2. Replace the content with the rules above
3. Click **"Publish"**

## 🎯 Step 3: Database Structure

Your application will automatically create a `tasks` collection with the following structure:

```
tasks/
  └── {taskId}/
      ├── id: string (UUID)
      ├── title: string
      ├── taskDescription: string
      ├── isCompleted: boolean
      ├── priority: string ("Urgent", "Important", "Normal")
      ├── category: string ("Patient Care", "Medications", etc.)
      ├── patientId: string? (optional)
      ├── dueTime: timestamp? (optional)
      ├── createdAt: timestamp
      └── completedAt: timestamp? (optional)
```

## 🎯 Step 4: Verify the Connection

### In your application:

1. **Launch the application** in the simulator or on a device
2. **Add a task** via the interface
3. **Return to the Firebase console** → Firestore Database → Data
4. **You should see**:
   - A `tasks` collection appear
   - Documents with your task IDs
   - Your task data in each document

### Synchronization test:

1. **Add a task in the app**
2. **Verify it appears in Firestore** (refresh the page)
3. **Modify a task in Firestore** (click on a document, modify a field, save)
4. **Return to the app** - the modification should appear automatically (real-time synchronization)

## 🔧 Troubleshooting

### Problem: Data doesn't appear in Firestore

**Solutions:**
1. Verify that Firebase is properly configured in `CubstartApp.swift`
2. Check Xcode logs to see if there are errors
3. Verify that Firestore rules allow writing
4. Verify that the `FirebaseFirestore` package is properly installed

### Problem: "Permission denied" error

**Solutions:**
1. Check Firestore rules (Rules tab)
2. Make sure the rules allow read/write
3. If you're using authentication, verify that the user is logged in

### Problem: Synchronization doesn't work

**Solutions:**
1. Check your internet connection
2. Verify that `TaskSyncService.shared.startSyncing()` is called in `CubstartApp.swift`
3. Check Xcode logs for errors

## 📱 Testing on Multiple Devices

To test synchronization between devices:

1. **Install the app on two different devices/simulators**
2. **Add a task on the first device**
3. **The task should appear automatically on the second device** (real-time synchronization)

## 🎉 It's Done!

Your application is now connected to Firestore! All tasks will be:
- ✅ Saved locally (SwiftData)
- ✅ Synchronized with Firestore (cloud)
- ✅ Available on all your devices
- ✅ Synchronized in real-time

## 📚 Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [iOS Firestore Guide](https://firebase.google.com/docs/firestore/quickstart#ios)

