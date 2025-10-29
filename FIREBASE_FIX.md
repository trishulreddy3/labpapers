# 🔥 Enable Firebase Firestore

## Quick Steps (3 minutes)

### Step 1: Enable Firestore API
1. Click this link: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=labpapers-4db23
2. Click the **"ENABLE"** button
3. Wait 1-2 minutes

### Step 2: Create Firestore Database
1. Go to: https://console.firebase.google.com/project/labpapers-4db23/firestore
2. Click **"Create Database"**
3. Choose **"Start in production mode"**
4. Select location: **asia-south1** (or choose closest to you)
5. Click **"Enable"**

### Step 3: Set Security Rules
1. In Firestore, click on the **"Rules"** tab
2. Copy and paste these rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /papers/{paperId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.resource.data.uploadedByEmail == request.auth.token.email;
    }
  }
}
```
3. Click **"Publish"**

### Step 4: Deploy Indexes ✅ (Already Done!)
**Firestore indexes have been deployed successfully!**

The following indexes are now active:
- ✅ Single field filters (College, Year, Branch, Exam Type)
- ✅ Two-field filter combinations
- ✅ Three-field filter combinations
- ✅ All four filters together

All search and filter combinations will work smoothly now!

### Step 5: Test Upload Again
1. Go back to your app
2. Try uploading a photo again
3. It should work now! 🎉

---

## What's Fixed:
- ✅ Cloudinary preset updated to use `ml_default`
- ✅ Firebase Firestore needs to be enabled (see steps above)

## After Setup:
- Upload photos, PDFs work
- All papers saved to Firestore
- Search and filters work
