# 📱 Notification Setup Instructions

## Why Notifications Aren't Working

Your app is creating notification records in Firestore, but **actual push notifications require a Firebase Server Key** to send FCM messages.

## ✅ Steps to Enable Push Notifications

### 1. Get Your Firebase Server Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click the ⚙️ **gear icon** → **Project Settings**
4. Go to **Cloud Messaging** tab
5. Find **Cloud Messaging API (Legacy)** section
6. Copy the **Server Key** (starts with `AAAA...`)

### 2. Add Server Key to Your App

1. Open `lib/services/notification_service.dart`
2. Find this line (around line 13):
   ```dart
   static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY_HERE';
   ```
3. Replace `YOUR_FIREBASE_SERVER_KEY_HERE` with your actual server key:
   ```dart
   static const String _serverKey = 'AAAAxxxxxxxxxxxxxxx:APA91b...';
   ```

### 3. Test Notifications

1. Run your app
2. Make sure you're logged in
3. Like or download someone else's paper
4. The owner should receive a push notification! 🎉

## 🔍 Troubleshooting

### Notifications Still Not Working?

1. **Check if FCM token is saved:**
   - Open your Firestore database
   - Check `users` collection
   - Look for a user document with `fcmToken` field

2. **Check console logs:**
   - Look for `⚠️ Warning: Firebase Server Key not configured`
   - Or `Push notification sent successfully`
   - Or `No FCM token found for user: {userId}`

3. **Verify permissions:**
   - Make sure you granted notification permissions when the app asked
   - Settings > Apps > Your App > Notifications (ON)

4. **Test on different devices:**
   - Notifications won't appear on the same device/user
   - Use a different account to like/download your papers

## 📝 How It Works

1. **User A** likes a paper uploaded by **User B**
2. App creates a Firestore notification document
3. App fetches **User B's** FCM token
4. App sends push notification via FCM to **User B**
5. **User B** receives the notification on their device! 🔔

## 🔐 Security Note

The server key in your app is used only to send notifications. However, for production apps, it's better to:
- Use Firebase Cloud Functions to send notifications
- Keep the server key on your backend
- Never expose it in client apps

For testing and small apps, this works fine though!

