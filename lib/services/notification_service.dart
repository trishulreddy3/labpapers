import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Firebase server key for sending push notifications
  static const String _serverKey = 'BEnnR5xXubSr77mBB31zgk8hjtkdxoWoiZDcAWsDjZbNzpGvBZGu1VVMjm3KPiqyspEqC3odEYwdZ2Yb-XAn1Iw';
  
  static Future<void> initialize(String userId) async {
    print('🔔 Initializing notifications for user: $userId');
    
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('📱 Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Create notification channel for Android
      await _createNotificationChannel();
      
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('📨 Notification tapped: ${response.payload}');
        },
      );

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: ${token?.substring(0, 20)}...');
      
      if (token != null) {
        await saveFCMToken(token, userId);
      } else {
        print('⚠️ Failed to get FCM token');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM token refreshed');
        saveFCMToken(newToken, userId);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Received foreground message: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      print('✅ Notifications initialized successfully');
    } else {
      print('❌ Notification permission denied');
    }
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'papers_notifications', // id
      'Papers Notifications', // title
      description: 'Notifications for papers app',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    print('📢 Created notification channel');
  }

  static Future<void> saveFCMToken(String token, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'papers_notifications',
      'Papers Notifications',
      channelDescription: 'Notifications for papers app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  // Get FCM token for a user
  static Future<String?> getUserFCMToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return doc.data()!['fcmToken'] as String?;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
    return null;
  }

  // Send push notification via FCM
  static Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    print('📤 Sending push notification to token: ${fcmToken.substring(0, 20)}...');

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
        }),
      );

      print('📬 FCM Response status: ${response.statusCode}');
      print('📬 FCM Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Push notification sent successfully!');
      } else {
        print('❌ Failed to send push notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending push notification: $e');
    }
  }

  // Create notification in Firestore and send push notification
  static Future<void> createNotification({
    required String userId, // This is the Auth UID
    required String title,
    required String body,
    required String type, // 'like', 'download', 'upload'
    String? paperId,
    String? paperTitle,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 1. Create document in Firestore for in-app notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId, // Auth UID
        'title': title,
        'body': body,
        'type': type,
        'paperId': paperId,
        'paperTitle': paperTitle,
        'data': data,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Send push notification
      final fcmToken = await getUserFCMToken(userId);
      if (fcmToken != null) {
        await sendPushNotification(
          fcmToken: fcmToken,
          title: title,
          body: body,
          data: {
            'type': type,
            'paperId': paperId,
            ...?data,
          },
        );
      } else {
        print('No FCM token found for user: $userId');
      }
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
