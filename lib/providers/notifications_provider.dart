import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? paperId;
  final String? paperTitle;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.paperId,
    this.paperTitle,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      paperId: map['paperId'],
      paperTitle: map['paperTitle'],
      data: map['data'] as Map<String, dynamic>?,
      read: map['read'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class NotificationsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  void loadNotifications(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          paperId: _notifications[index].paperId,
          paperTitle: _notifications[index].paperTitle,
          data: _notifications[index].data,
          read: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds = _notifications.where((n) => !n.read).map((n) => n.id);
      
      final batch = _firestore.batch();
      for (final id in unreadIds) {
        batch.update(_firestore.collection('notifications').doc(id), {'read': true});
      }
      await batch.commit();
      
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].read) {
          _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            userId: _notifications[i].userId,
            title: _notifications[i].title,
            body: _notifications[i].body,
            type: _notifications[i].type,
            paperId: _notifications[i].paperId,
            paperTitle: _notifications[i].paperTitle,
            data: _notifications[i].data,
            read: true,
            createdAt: _notifications[i].createdAt,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final allIds = _notifications.map((n) => n.id);
      
      final batch = _firestore.batch();
      for (final id in allIds) {
        batch.delete(_firestore.collection('notifications').doc(id));
      }
      await batch.commit();
      
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }
}


