import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/branch_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../providers/vendor_order_provider.dart';
import '../../widgets/branch_selector_modal.dart';
import '../../widgets/stat_card.dart';
import '../delivery_hours/branch_delivery_hours_screen.dart';
import '../notifications/vendor_notifications_screen.dart';
import '../order/vendor_orders_screen.dart';
import '../riders/rider_management_screen.dart';
import '../staff/staff_management_screen.dart';
import '../subscription/subscription_screen.dart';

class BranchDashboardScreen extends StatefulWidget {
  const BranchDashboardScreen({super.key});

  @override
  State<BranchDashboardScreen> createState() => _BranchDashboardScreenState();
}

class _BranchDashboardScreenState extends State<BranchDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final branchProv = context.read<BranchProvider>();
    final orderProv = context.read<VendorOrderProvider>();
    final invProv = context.read<InventoryProvider>();
    final subProv = context.read<SubscriptionProvider>();

    await subProv.fetchSubscriptionData();

    if (branchProv.currentBranchId != null) {
      await Future.wait([
        orderProv.fetchOrders(branchId: branchProv.currentBranchId),
        invProv.fetchInventory(branchProv.currentBranchId!),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final branchProv = context.watch<BranchProvider>();
    final orderProv = context.watch<VendorOrderProvider>();
    final invProv = context.watch<InventoryProvider>();
    final subProv = context.watch<SubscriptionProvider>();
    final currentSub = subProv.currentSubscription;

    final branch = branchProv.selectedBranch;
    final pendingCount = orderProv.unacknowledgedPendingCount;

    // Calculate today's orders & revenue
    final now = DateTime.now();
    final todayOrders = orderProv.orders.where((o) {
      return o.createdAt.year == now.year &&
          o.createdAt.month == now.month &&
          o.createdAt.day == now.day &&
          o.status != VendorOrderStatus.cancelled &&
          o.status != VendorOrderStatus.rejected;
    }).toList();

    final todayRevenuePaisa = todayOrders.fold(0, (sum, o) => sum + o.totalPaisa);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: InkWell(
          onTap: () => BranchSelectorModal.show(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  branch?.name ?? loc.tr('branchSelector'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VendorNotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subscription Inactive / Pending Payment Alert Banner
              if (currentSub?.isActive != true) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.isBangla ? 'সাবস্ক্রিপশন প্ল্যান প্রয়োজন' : 'Subscription Inactive',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.isBangla
                                  ? 'কাস্টমার অর্ডার পেতে প্ল্যান সক্রিয় করুন।'
                                  : 'Activate a partner plan to accept orders.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SubscriptionScreen(canGoBack: true)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          loc.isBangla ? 'প্ল্যান দেখুন' : 'View Plans',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Branch Status Card (Open / Closed)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: branch?.isOpen == true ? AppTheme.success : AppTheme.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch?.isOpen == true ? loc.tr('branchOpen') : loc.tr('branchClosed'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: branch?.isOpen == true ? AppTheme.success : AppTheme.danger,
                                ),
                              ),
                              Text(
                                branch?.isOpen == true
                                    ? (loc.isBangla ? 'গ্রাহকদের কাছ থেকে অর্ডার গ্রহণ চলছে' : 'Accepting customer orders')
                                    : (loc.isBangla ? 'বর্তমানে নতুন অর্ডার গ্রহণ বন্ধ রয়েছে' : 'Not accepting orders right now'),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: branch?.isOpen ?? false,
                        activeTrackColor: AppTheme.success,
                        onChanged: (val) => branchProv.toggleBranchStatus(val),
                      ),
                    ],
                  ),
                ),
              ),

              // Pending Orders Alarm Banner
              if (pendingCount > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFCCAA), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('newOrderAlert'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF993D00),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.isBangla
                                  ? '$pendingCount টি নতুন অর্ডার আপনার অনুমোদনের অপেক্ষায়।'
                                  : '$pendingCount new order(s) waiting for response.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF993D00)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const VendorOrdersScreen()),
                          );
                        },
                        child: Text(loc.tr('viewOrder'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Summary Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: loc.tr('todaysOrders'),
                    value: '${todayOrders.length}',
                    icon: Icons.shopping_bag_outlined,
                    color: AppTheme.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VendorOrdersScreen()),
                      );
                    },
                  ),
                  StatCard(
                    title: loc.tr('todaysRevenue'),
                    value: loc.isBangla
                        ? Money(todayRevenuePaisa).formatBangla()
                        : Money(todayRevenuePaisa).format(),
                    icon: Icons.payments_outlined,
                    color: AppTheme.success,
                  ),
                  StatCard(
                    title: loc.tr('pendingOrders'),
                    value: '$pendingCount',
                    icon: Icons.hourglass_empty,
                    color: AppTheme.warning,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VendorOrdersScreen()),
                      );
                    },
                  ),
                  StatCard(
                    title: loc.tr('lowStockThreshold'),
                    value: '${invProv.lowStockCount}',
                    icon: Icons.warning_amber_rounded,
                    color: invProv.lowStockCount > 0 ? AppTheme.danger : AppTheme.textMuted,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Operational Navigation Menu
              Text(
                loc.isBangla ? 'ব্রাঞ্চ কার্যক্রম' : 'Branch Operations',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule, color: AppTheme.primary),
                      title: Text(loc.tr('deliveryHours'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        loc.isBangla ? 'সাপ্তাহিক ৭ দিনের ডেলিভারি সময়সূচি' : 'Saturday-first 7-day operating schedule',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BranchDeliveryHoursScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delivery_dining, color: AppTheme.primary),
                      title: Text(loc.tr('riders'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        loc.isBangla ? 'ডেলিভারি রাইডার ও অ্যাসাইনমেন্ট' : 'Manage branch delivery riders',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RiderManagementScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.card_membership, color: AppTheme.primary),
                      title: Text(loc.tr('subscription'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        loc.isBangla ? 'ভেন্ডর প্যাকেজ ও রিনিউ স্ট্যাটাস' : 'Plan status & payment submission',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                        );
                      },
                    ),
                    if (auth.role.canManageStaff) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.people_outline, color: AppTheme.primary),
                        title: Text(loc.tr('staffManagement'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          loc.isBangla ? 'ম্যানেজার ও স্টাফ আমন্ত্রণ ও নিয়ন্ত্রণ' : 'Invite staff & assign branch roles',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
