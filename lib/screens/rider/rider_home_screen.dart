import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/rider_delivery_model.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../dashboard/vendor_main_navigation_shell.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<RiderDeliveryProvider>();
      prov.fetchAssignedDeliveries();
      prov.fetchAvailableDeliveries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final prov = context.read<RiderDeliveryProvider>();
    await Future.wait([
      prov.fetchAssignedDeliveries(),
      prov.fetchAvailableDeliveries(),
    ]);
  }

  void _callPhone(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMap(String address) async {
    if (address.isEmpty) return;
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showCompleteDeliveryDialog(
    BuildContext context,
    RiderDeliveryTask task,
  ) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.success),
              SizedBox(width: 8),
              Text(
                'Complete Delivery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm cylinder delivery for order #${task.orderNumber ?? task.orderId.substring(0, 8)}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount to Collect:', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    Text(
                      task.paymentMethod == 'COD'
                          ? '৳${task.payableAmount.toStringAsFixed(0)} (Cash)'
                          : '৳0 (Already Paid Online)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: task.paymentMethod == 'COD'
                            ? AppTheme.primary
                            : AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Customer Delivery OTP (Optional)',
                  hintText: '4-digit OTP from customer app',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final prov = context.read<RiderDeliveryProvider>();
                final ok = await prov.markDelivered(
                  task.deliveryId,
                  otp: otpController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Delivery completed successfully! 🎉'
                            : (prov.error ?? 'Failed to complete delivery'),
                      ),
                      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                    ),
                  );
                }
              },
              child: const Text('Confirm Delivered'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final riderProv = context.watch<RiderDeliveryProvider>();
    final authProv = context.watch<VendorAuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.isBangla ? 'রাইডার ডেলিভারি ড্যাশবোর্ড' : 'Rider Delivery Hub',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  loc.isBangla ? 'অন ডিউটি / একটিভ' : 'On Duty · Active',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (authProv.vendorProfile != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 16),
                label: Text(
                  loc.isBangla ? 'দোকান ভিউ' : 'Store View',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const VendorMainNavigationShell(),
                    ),
                  );
                },
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              text: loc.isBangla
                  ? 'একটিভ (${riderProv.activeDeliveries.length})'
                  : 'Active (${riderProv.activeDeliveries.length})',
            ),
            Tab(
              text: loc.isBangla
                  ? 'নতুন রিকোয়েস্ট (${riderProv.availableDeliveries.length})'
                  : 'Available (${riderProv.availableDeliveries.length})',
            ),
            Tab(
              text: loc.isBangla
                  ? 'সম্পন্ন (${riderProv.completedDeliveries.length})'
                  : 'History (${riderProv.completedDeliveries.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Active Deliveries
          RefreshIndicator(
            onRefresh: _refresh,
            child: riderProv.isLoading && riderProv.assignedDeliveries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : riderProv.activeDeliveries.isEmpty
                    ? EmptyStateView(
                        icon: Icons.delivery_dining_outlined,
                        title: loc.isBangla
                            ? 'কোনো একটিভ ডেলিভারি নেই'
                            : 'No Active Deliveries',
                        message: loc.isBangla
                            ? 'নতুন গ্যাস সিলিন্ডার অর্ডারের জন্য অপেক্ষা করুন বা অ্যাভেইলেবল ট্যাব চেক করুন।'
                            : 'You have no assigned deliveries right now. Check the Available tab.',
                        actionText: loc.isBangla ? 'রিফ্রেশ করুন' : 'Refresh',
                        onAction: _refresh,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: riderProv.activeDeliveries.length,
                        itemBuilder: (ctx, index) {
                          final task = riderProv.activeDeliveries[index];
                          return _buildDeliveryCard(task, isAvailable: false);
                        },
                      ),
          ),

          // TAB 2: Available Platform Deliveries
          RefreshIndicator(
            onRefresh: _refresh,
            child: riderProv.availableDeliveries.isEmpty
                ? EmptyStateView(
                    icon: Icons.electric_moped_outlined,
                    title: loc.isBangla
                        ? 'কোনো অন-ডিমান্ড রিকোয়েস্ট নেই'
                        : 'No On-Demand Requests',
                    message: loc.isBangla
                        ? 'গ্যাস লাগবা সেন্ট্রাল ডেলিভারি পুল থেকে নতুন অর্ডার আসলে এখানে প্রদর্শিত হবে।'
                        : 'When vendors request Gas Lagba platform riders, jobs will appear here.',
                    actionText: loc.isBangla ? 'রিফ্রেশ করুন' : 'Refresh',
                    onAction: _refresh,
                  )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: riderProv.availableDeliveries.length,
                        itemBuilder: (ctx, index) {
                          final task = riderProv.availableDeliveries[index];
                          return _buildDeliveryCard(task, isAvailable: true);
                        },
                      ),
          ),

          // TAB 3: History
          RefreshIndicator(
            onRefresh: _refresh,
            child: riderProv.completedDeliveries.isEmpty
                ? EmptyStateView(
                    icon: Icons.history_outlined,
                    title: loc.isBangla
                        ? 'কোনো সম্পন্ন ডেলিভারি নেই'
                        : 'No Delivery History',
                    message: loc.isBangla
                        ? 'আপনার সফলভাবে ডেলিভার করা সিলিন্ডারগুলো এখানে সংরক্ষিত থাকবে।'
                        : 'Your delivered orders and completed runs will show here.',
                  )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: riderProv.completedDeliveries.length,
                        itemBuilder: (ctx, index) {
                          final task = riderProv.completedDeliveries[index];
                          return _buildDeliveryCard(task, isAvailable: false);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(RiderDeliveryTask task, {required bool isAvailable}) {
    final loc = context.read<LocaleProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order Number, Payment Status, Delivery State
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${task.orderNumber ?? task.orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (task.deliveryType == 'PLATFORM_RIDER')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🚀 Central',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isDelivered
                        ? AppTheme.success.withValues(alpha: 0.12)
                        : task.isPickedUp
                            ? Colors.blue.withValues(alpha: 0.12)
                            : Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.isDelivered
                        ? (loc.isBangla ? 'ডেলিভার্ড' : 'Delivered')
                        : task.isPickedUp
                            ? (loc.isBangla ? 'পথে রয়েছে' : 'On The Way')
                            : (loc.isBangla ? 'পিকআপের অপেক্ষায়' : 'Awaiting Pickup'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: task.isDelivered
                          ? AppTheme.success
                          : task.isPickedUp
                              ? Colors.blue.shade700
                              : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // STORE PICKUP LOCATION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFFFECE5),
                  child: Icon(Icons.storefront, size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'পিকআপ পয়েন্ট (দোকান):' : 'Pickup Store:',
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        task.store.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        task.store.address,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (task.store.phone != null && task.store.phone!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppTheme.primary),
                    onPressed: () => _callPhone(task.store.phone!),
                    tooltip: 'Call Store',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // CUSTOMER DELIVERY LOCATION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.location_on, size: 16, color: AppTheme.success),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'ডেলিভারি ঠিকানা (গ্রাহক):' : 'Deliver To:',
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        task.customer.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        task.customer.address,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (task.customer.phone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppTheme.success),
                    onPressed: () => _callPhone(task.customer.phone),
                    tooltip: 'Call Customer',
                  ),
                IconButton(
                  icon: const Icon(Icons.directions, color: Colors.blue),
                  onPressed: () => _openMap(task.customer.address),
                  tooltip: 'Google Maps Navigation',
                ),
              ],
            ),

            // ITEMS & PRICE SUMMARY
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '৳${task.payableAmount.toStringAsFixed(0)} (${task.paymentMethod})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ACTION BUTTONS ACCORDING TO TASK STATE
            if (isAvailable) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    loc.isBangla ? 'ডেলিভারি টাস্ক গ্রহণ করুন' : 'Accept Delivery Job',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final prov = context.read<RiderDeliveryProvider>();
                    final ok = await prov.acceptDelivery(task.deliveryId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Delivery accepted! Head to store for pickup.'
                                : (prov.error ?? 'Failed to accept delivery'),
                          ),
                          backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                        ),
                      );
                    }
                  },
                ),
              ),
            ] else if (!task.isDelivered) ...[
              if (!task.isPickedUp)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text(
                      loc.isBangla
                          ? 'সিলিন্ডার দোকান থেকে পিকআপ নিশ্চিত করুন'
                          : 'Confirm Cylinder Picked Up from Store',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final prov = context.read<RiderDeliveryProvider>();
                      final ok = await prov.markPickedUp(task.deliveryId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Pickup confirmed! Now delivering to customer.'
                                  : (prov.error ?? 'Failed to confirm pickup'),
                            ),
                            backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                          ),
                        );
                      }
                    },
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.verified, size: 18),
                    label: Text(
                      loc.isBangla
                          ? 'গ্রাহককে ডেলিভার সম্পন্ন করুন'
                          : 'Complete Delivery to Customer',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showCompleteDeliveryDialog(context, task),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
