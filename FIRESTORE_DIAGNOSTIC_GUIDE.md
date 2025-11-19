# 🔍 Firestore Diagnostic Guide

This guide helps you identify why data is not appearing in Firestore.

## 📋 Diagnostic Steps

### 1. Check Logs in Xcode

Detailed logs have been added to the code. Follow these steps:

1. **Open Xcode**
2. **Launch the application** in the simulator (⌘R)
3. **Open the console**: View → Debug Area → Activate Console (or ⌘⇧Y)
4. **Create a new task** in the app
5. **Look at the messages in the console**

#### Expected Messages (if everything works):

```
🔥 [AppDelegate] Configuring Firebase...
✅ [AppDelegate] Firebase configured successfully!
🚀 [CubstartApp] Application started, initializing Firestore synchronization...
✅ [CubstartApp] Firebase is initialized
🔄 [CubstartApp] Starting Firestore listener...
🔄 [CubstartApp] Initial task synchronization...
✅ [AddTaskView] Task saved locally: [Your task title]
🔄 [AddTaskView] Starting Firestore synchronization...
🔄 [TaskSyncService] Starting task synchronization: [Title]
🔥 [FirestoreService] Attempting to save task: [UUID]
🔥 [FirestoreService] Title: [Title]
🔥 [FirestoreService] Dictionary created: [...]
🔥 [FirestoreService] Collection: tasks
🔥 [FirestoreService] Document ID: [UUID]
✅ [FirestoreService] Task saved successfully to Firestore!
✅ [TaskSyncService] Synchronization successful for: [Title]
```

### 2. Common Problems and Solutions

#### ❌ Problem: "Firebase is not initialized"

**Error message:**
```
❌ [AppDelegate] Error: Firebase could not be configured!
❌ [CubstartApp] Firebase is not initialized!
```

**Solutions:**
1. Verify that the `GoogleService-Info.plist` file is present in the project
2. Verify that the file is added to the "Cubstart" target
3. Verify that the Bundle ID matches in Xcode and Firebase

#### ❌ Problem: "Permission denied" or rules error

**Error message:**
```
❌ [FirestoreService] Error saving: Permission denied
Error code: 7
```

**Solutions:**
1. Go to Firebase Console → Firestore → Rules
2. Make sure you have these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

3. Click **"Publish"**

#### ❌ Problem: FirebaseFirestore Package Not Installed

**Error message:**
```
No such module 'FirebaseFirestore'
```

**Solutions:**
1. In Xcode, go to **File > Add Package Dependencies...**
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select **FirebaseFirestore** in the products
4. Click **Add Package**

#### ❌ Problem: Collection "Tasks" instead of "tasks"

**Symptom**: Data doesn't appear but no error in logs

**Solution:**
1. Delete the "Tasks" collection (with capital T) in Firebase if it exists
2. The code uses "tasks" (lowercase) - the collection will be created automatically

### 3. Verify Firestore Security Rules

1. **Open Firebase Console**: https://console.firebase.google.com
2. **Select your project**: "Cubstart"
3. **Go to Firestore Database → Rules**
4. **Verify you have**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Important**: These rules allow EVERYONE to access the data. For production, add authentication.

### 4. Manual Test in Firebase Console

To verify that Firestore works:

1. **In Firebase Console → Firestore → Data**
2. **Click on "+ Start a collection"**
3. **Collection ID**: `tasks`
4. **Document ID**: Leave empty (auto-generated)
5. **Add a field**:
   - Field: `test`
   - Type: `string`
   - Value: `hello`
6. **Save**

If this works, Firestore is properly configured. The problem comes from the app code.

### 5. Check Internet Connection

Make sure:
- The simulator/device has internet access
- No firewall is blocking Firebase
- You're not in airplane mode

### 6. Clean and Rebuild

Sometimes, cleaning the project resolves issues:

1. In Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. Close Xcode
3. Delete the `DerivedData` folder:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Cubstart-*
   ```
4. Reopen Xcode and rebuild

## 📊 Verification Checklist

Check each point:

- [ ] The `GoogleService-Info.plist` file is present in the project
- [ ] The `FirebaseFirestore` package is installed in Xcode
- [ ] Firestore rules allow writing (`allow read, write: if true`)
- [ ] The Firestore database is created in Firebase Console
- [ ] Xcode logs show "Firebase configured successfully"
- [ ] Xcode logs show "Task saved successfully to Firestore"
- [ ] The `tasks` collection (lowercase) is used in the code
- [ ] The device/simulator has internet access

## 🆘 If Nothing Works

If after following all these steps, data still doesn't appear:

1. **Copy all messages from the Xcode console** (especially those with ❌)
2. **Check Firestore rules** and take a screenshot
3. **Verify that FirebaseFirestore is properly installed** in Package Dependencies

The detailed logs will tell you exactly where the problem is!

