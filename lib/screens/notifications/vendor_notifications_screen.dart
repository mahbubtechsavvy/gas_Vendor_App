import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_view.dart';

class VendorNotificationsScreen extends StatefulWidget {
  const VendorNotificationsScreen({super.key});

  @override
  State<VendorNotificationsScreen> createState() => _VendorNotificationsScreenState();
}

class _VendorNotificationsScreenState extends State<VendorNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final notifProv = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.isBangla ? 'বিজ্ঞপ্তি' : 'Notifications'),
        actions: [
          if (notifProv.notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: Text(
                loc.isBangla ? 'সব পড়া হয়েছে' : 'Mark All Read',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifProv.fetchNotifications(),
        color: AppTheme.primary,
        child: notifProv.notifications.isEmpty
            ? EmptyStateView(
                icon: Icons.notifications_none,
                title: loc.isBangla ? 'কোনো বিজ্ঞপ্তি নেই' : 'No Notifications',
                message: loc.isBangla
                    ? 'আপনার কাছে কোনো নতুন নোটিফিকেশন নেই।'
                    : 'You will receive alerts about orders and status updates here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifProv.notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifProv.notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: notif.isRead ? AppTheme.surface : AppTheme.primaryLight.withValues(alpha: 0.3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: notif.isRead ? const Color(0xFFF1F5F9) : AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: notif.isRead ? AppTheme.textMuted : AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notif.body,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(notif.createdAt),
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (!notif.isRead) {
                          notifProv.markAsRead(notif.id);
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
