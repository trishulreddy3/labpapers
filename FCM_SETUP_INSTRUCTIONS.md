# Firebase Cloud Messaging (FCM) Setup Instructions

## For Real-Time Push Notifications

Your app now has real-time notification capabilities! Here's what needs to be set up:

### ✅ What's Already Implemented:
1. ✅ Notification service (`lib/services/notification_service.dart`)
2. ✅ Real-time notifications provider (`lib/providers/notifications_provider.dart`)
3. ✅ Firestore rules updated for notifications
4. ✅ Paper provider sends notifications on like/download
5. ✅ Dependencies installed (`firebase_messaging`, `flutter_local_notifications`)

### 🔧 Setup Required:

#### 1. Enable FCM in Firebase Console
- Go to Firebase Console (https://console.firebase.google.com)
- Select your project
- Go to "Project Settings" → "Cloud Messaging"
- Generate and download `google-services.json` (already done)

#### 2. Android Setup (Already Done ✅)
- `google-services.json` is already in `android/app/`
- Firebase Cloud Messaging is enabled

#### 3. Test Notifications
To test notifications manually:

```dart
// In your code, call:
await NotificationService.createNotification(
  userId: 'user_email_or_uid',
  title: 'Test Notification',
  body: 'This is a test notification!',
  type: 'test',
);
```

### 🎯 How It Works:

#### When a User Likes a Paper:
1. User likes a paper → `toggleLike()` is called
2. Notification created in Firestore for the paper owner
3. Real-time listener in `NotificationsProvider` picks it up
4. Badge count updates in UI
5. User sees notification in notification center

#### When a User Downloads a Paper:
1. User downloads a paper → `incrementDownload()` is called
2. Notification created in Firestore for the paper owner
3. Real-time listener picks it up
4. UI updates automatically

### 📱 Features Implemented:
- ✅ Real-time notification listener
- ✅ Unread badge count
- ✅ Mark as read functionality
- ✅ Delete notifications
- ✅ Automatic notifications on like/download
- ✅ Notification center integration (requires FCM server setup)

### 🚀 Next Steps for Production:

To enable **actual push notifications** (not just in-app), you need to set up a Cloud Function or server to send FCM messages when notifications are created in Firestore.

#### Option 1: Cloud Function (Recommended)
Create a Firebase Cloud Function that triggers when a notification document is created:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Get user's FCM token from Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(notification.userId)
      .get();
    
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return;
    
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      token: fcmToken,
      data: {
        paperId: notification.paperId || '',
        type: notification.type,
      },
    };
    
    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error('Error sending message:', error);
    }
  });
```

#### Option 2: Use Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Send test message to specific FCM tokens

### 📝 Important Notes:
- **Current Implementation**: Notifications are stored in Firestore and displayed in-app
- **Push Notifications**: Require Cloud Function setup for real device notifications
- **Testing**: Works perfectly with Firestore real-time listeners
- **Badge Count**: Updates automatically when new notifications arrive

### 🔔 Notification Types:
- `like` - When someone likes your paper
- `download` - When someone downloads your paper
- Custom types can be added

### 📊 Unread Badge:
The app shows an unread notification badge next to the notifications icon. This updates in real-time as new notifications arrive.

## Files Modified/Created:
- ✅ `lib/services/notification_service.dart` - Notification service
- ✅ `lib/providers/notifications_provider.dart` - Real-time provider
- ✅ `lib/providers/paper_provider.dart` - Sends notifications on actions
- ✅ `firestore.rules` - Updated for notifications
- ✅ `pubspec.yaml` - Added FCM dependencies

## Usage in Your App:

```dart
// Initialize when user logs in
await NotificationService.initialize(userId);

// Provider usage
final notificationsProvider = Provider.of<NotificationsProvider>(context);
notificationsProvider.loadNotifications(userId);

// Get unread count
final unreadCount = notificationsProvider.unreadCount;

// Mark as read
await notificationsProvider.markAsRead(notificationId);
```


