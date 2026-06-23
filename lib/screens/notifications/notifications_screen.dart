import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Order Received',
        'message': 'You have a new order #12345 from Karim.',
        'time': '2 mins ago',
        'isRead': false,
        'type': 'order',
      },
      {
        'title': 'Order Delivered',
        'message': 'Order #12342 has been successfully delivered.',
        'time': '1 hour ago',
        'isRead': true,
        'type': 'success',
      },
      {
        'title': 'Low Stock Alert',
        'message': 'Your stock for "12kg Cylinder" is running low.',
        'time': '3 hours ago',
        'isRead': true,
        'type': 'alert',
      },
      {
        'title': 'System Update',
        'message': 'The app will be under maintenance tonight at 2 AM.',
        'time': '1 day ago',
        'isRead': true,
        'type': 'info',
      },
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read logic
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    IconData icon;
    Color color;

    switch (notification['type']) {
      case 'order':
        icon = Icons.shopping_bag;
        color = ThemeConfig.primaryColor;
        break;
      case 'success':
        icon = Icons.check_circle;
        color = ThemeConfig.successColor;
        break;
      case 'alert':
        icon = Icons.warning;
        color = ThemeConfig.warningColor;
        break;
      default:
        icon = Icons.info;
        color = ThemeConfig.infoColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead']
            ? Colors.white
            : ThemeConfig.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead']
              ? Colors.transparent
              : ThemeConfig.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['isRead']
                            ? FontWeight.w600
                            : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        color: ThemeConfig.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: ThemeConfig.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
