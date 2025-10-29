# 🔧 Quick Fix Guide

## Issue 1: Cloud Firestore API Not Enabled

**Error**: `Cloud Firestore API has not been used in project labpapers-4db23 before or it is disabled`

### Solution:
1. **Click this link**: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=labpapers-4db23
2. Click the **"ENABLE"** button at the top
3. Wait 2-3 minutes for the API to activate

### Then Create the Database:
1. Go to: https://console.firebase.google.com/project/labpapers-4db23/firestore
2. Click **"Create Database"**
3. Choose **"Start in production mode"**
4. Select a location (choose **asia-south1** or **us-central1**)
5. Click **"Enable"**

---

## Issue 2: Cloudinary Upload Preset Not Found

**Error**: `Upload preset not found`

### Solution:

#### Step 1: Create the Upload Preset
1. Go to: https://cloudinary.com/console/c/dyudoronx/settings/upload
2. Scroll down to **"Upload presets"** section
3. Click **"Add upload preset"** button
4. Fill in:
   - **Upload preset name**: `question_papers_preset`
   - **Signing mode**: Select **"Unsigned"** (important!)
   - **Folder**: Type `question_papers`
   - **Allowed formats**: Check `pdf`, `jpg`, `png`, `jpeg`
   - **Max file size**: `50` MB
5. Click **"Save"** at the bottom

#### Step 2: Verify the Preset
- The preset name must be exactly: `question_papers_preset`
- It should show as "Unsigned" mode
- It should be in your upload presets list

---

## 🧪 Test After Setup

After completing both steps above:

1. **Hot restart** the app in your terminal (press `R`)
2. Try uploading a photo again
3. If it still fails, wait 5 minutes and try again (APIs take time to propagate)

---

## 📝 Current Status

- ✅ Code is complete and working
- ✅ All integrations are properly configured
- ⚠️ Just need to enable Firebase and create Cloudinary preset
- ⚠️ Both are one-time setup steps

---

## 🆘 Still Having Issues?

If upload still doesn't work after completing both steps:

1. **Check Firebase**: Make sure Firestore database is created
2. **Check Cloudinary**: Verify preset name is exactly `question_papers_preset` and it's marked as "Unsigned"
3. **Restart**: Hot restart the app (press `R` in terminal)
4. **Wait**: Sometimes takes 5-10 minutes for changes to propagate

---

## 🎯 Expected Result

After setup:
- ✅ Photos/PDFs upload to Cloudinary
- ✅ Paper data saves to Firestore
- ✅ You can view papers in the app
- ✅ Search and filters work

Good luck! 🚀
