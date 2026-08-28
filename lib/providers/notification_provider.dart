import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.notifications);
      if (res is List) {
        _notifications = res.map((e) => NotificationModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['notifications'] is List) {
        _notifications = (res['notifications'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client.patch(ApiEndpoints.markNotificationRead(notificationId));
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final current = _notifications[idx];
        _notifications[idx] = NotificationModel(
          id: current.id,
          title: current.title,
          body: current.body,
          category: current.category,
          isRead: true,
          metadata: current.metadata,
          createdAt: current.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.post(ApiEndpoints.markAllNotificationsRead);
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                category: n.category,
                isRead: true,
                metadata: n.metadata,
                createdAt: n.createdAt,
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark all as read: $e');
    }
  }
}
