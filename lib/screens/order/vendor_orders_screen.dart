import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/branch_provider.dart';
import '../../providers/vendor_order_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/money_text.dart';
import '../../widgets/status_badge.dart';
import 'vendor_order_detail_screen.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final branchId = context.read<BranchProvider>().currentBranchId;
      context.read<VendorOrderProvider>().fetchOrders(branchId: branchId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final orderProv = context.watch<VendorOrderProvider>();
    final branchId = context.watch<BranchProvider>().currentBranchId;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('orders')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            Tab(
              child: Row(
                children: [
                  Text(loc.isBangla ? 'নতুন' : 'Pending'),
                  if (orderProv.pendingOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                      child: Text(
                        '${orderProv.pendingOrders.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: loc.isBangla ? 'গৃহীত' : 'Accepted'),
            Tab(text: loc.isBangla ? 'প্রস্তুতি' : 'Preparing'),
            Tab(text: loc.isBangla ? 'প্রস্তুত' : 'Ready'),
            Tab(text: loc.isBangla ? 'চলমান' : 'Dispatched'),
            Tab(text: loc.isBangla ? 'সম্পন্ন' : 'History'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(branchId: branchId),
        color: AppTheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(context, orderProv.pendingOrders, loc, 'No pending orders'),
            _buildOrderList(context, orderProv.acceptedOrders, loc, 'No accepted orders'),
            _buildOrderList(context, orderProv.preparingOrders, loc, 'No orders being prepared'),
            _buildOrderList(context, orderProv.readyOrders, loc, 'No ready orders'),
            _buildOrderList(context, orderProv.outForDeliveryOrders, loc, 'No dispatched orders'),
            _buildOrderList(context, orderProv.historyOrders, loc, 'No completed orders yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<VendorOrderModel> orders,
    LocaleProvider loc,
    String emptyMessage,
  ) {
    if (orders.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: loc.isBangla ? 'কোনো অর্ডার নেই' : 'No Orders Found',
        message: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VendorOrderDetailScreen(orderId: order.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      Text(
                        DateFormat('hh:mm a').format(order.createdAt),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.deliveryAddressText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (order.hasCancellationRequest) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.danger),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              loc.isBangla ? 'গ্রাহক অর্ডার বাতিল করার অনুরোধ করেছেন!' : 'Customer requested cancellation!',
                              style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('${loc.isBangla ? 'মোট: ' : 'Total: '} ', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          MoneyText(
                            money: order.total,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            loc.isBangla ? 'বিস্তারিত' : 'View Details',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
