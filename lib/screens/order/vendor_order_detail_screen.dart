import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/rider_provider.dart';
import '../../providers/vendor_order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';
import '../../widgets/status_badge.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorOrderProvider>().fetchOrderDetails(widget.orderId);
      context.read<RiderProvider>().fetchRiders();
    });
  }

  void _showRejectDialog(VendorOrderModel order) {
    final loc = context.read<LocaleProvider>();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.tr('rejectOrderTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.isBangla
                  ? 'অর্ডারটি প্রত্যাখ্যান করলে স্টক পুনরায় উদ্ধার হবে এবং গ্রাহককে জানানো হবে।'
                  : 'Rejecting this order will restore reserved stock and notify the customer.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: loc.tr('rejectReasonLabel'),
                hintText: loc.isBangla ? 'যেমন: স্টক শেষ / ডেলিভারি বাইরে' : 'e.g. Out of stock',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              final orderProv = context.read<VendorOrderProvider>();
              await orderProv.rejectOrder(order.id, reason.isNotEmpty ? reason : 'Vendor unable to fulfill');
            },
            child: Text(loc.tr('reject')),
          ),
        ],
      ),
    );
  }

  void _showDispatchDialog(VendorOrderModel order) {
    final loc = context.read<LocaleProvider>();
    final riderProv = context.read<RiderProvider>();
    String selectedMode = 'STAFF_RIDER'; // 'SELF', 'STAFF_RIDER', 'PLATFORM_RIDER'
    String? selectedRiderId = riderProv.riders.isNotEmpty ? riderProv.riders.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.delivery_dining, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  loc.isBangla ? 'ডেলিভারি মাধ্যম নির্বাচন করুন' : 'Select Delivery Mode',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Option 1: Deliver Myself
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectedMode == 'SELF' ? AppTheme.primary : Colors.black12,
                        width: selectedMode == 'SELF' ? 2 : 1,
                      ),
                    ),
                    tileColor: selectedMode == 'SELF' ? AppTheme.primary.withValues(alpha: 0.05) : null,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFECE5),
                      child: Icon(Icons.person_pin_circle, color: AppTheme.primary, size: 20),
                    ),
                    title: Text(
                      loc.isBangla ? 'আমি নিজেই ডেলিভার করব' : 'Deliver Myself (Owner)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      loc.isBangla ? 'দোকানের মালিক সরাসরি গ্রাহককে ডেলিভার করবেন।' : 'Store owner delivers directly to customer.',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    trailing: Radio<String>(
                      value: 'SELF',
                      groupValue: selectedMode,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    onTap: () => setModalState(() => selectedMode = 'SELF'),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Staff Rider
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectedMode == 'STAFF_RIDER' ? AppTheme.primary : Colors.black12,
                        width: selectedMode == 'STAFF_RIDER' ? 2 : 1,
                      ),
                    ),
                    tileColor: selectedMode == 'STAFF_RIDER' ? AppTheme.primary.withValues(alpha: 0.05) : null,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.groups, color: Colors.blue, size: 20),
                    ),
                    title: Text(
                      loc.isBangla ? 'আমার দোকানের স্টাফ রাইডার' : 'My In-House Staff Rider',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.isBangla ? 'দোকানের নিয়োজিত রাইডারদের একজনকে দায়িত্ব দিন।' : 'Assign to an employed store rider.',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        if (selectedMode == 'STAFF_RIDER') ...[
                          const SizedBox(height: 8),
                          if (riderProv.riders.isEmpty)
                            Text(
                              loc.isBangla ? 'কোনো অনুমোদিত রাইডার নেই।' : 'No approved riders found.',
                              style: const TextStyle(fontSize: 11, color: AppTheme.danger, fontWeight: FontWeight.bold),
                            )
                          else
                            DropdownButtonFormField<String>(
                              initialValue: selectedRiderId,
                              isDense: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Staff Rider',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              items: riderProv.riders.map((r) {
                                return DropdownMenuItem(
                                  value: r.id,
                                  child: Text('${r.fullName} (${r.phone})', style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) => setModalState(() => selectedRiderId = val),
                            ),
                        ],
                      ],
                    ),
                    trailing: Radio<String>(
                      value: 'STAFF_RIDER',
                      groupValue: selectedMode,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    onTap: () => setModalState(() => selectedMode = 'STAFF_RIDER'),
                  ),
                  const SizedBox(height: 10),

                  // Option 3: Request Gas Lagba Central Rider
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectedMode == 'PLATFORM_RIDER' ? Colors.purple : Colors.black12,
                        width: selectedMode == 'PLATFORM_RIDER' ? 2 : 1,
                      ),
                    ),
                    tileColor: selectedMode == 'PLATFORM_RIDER' ? Colors.purple.withValues(alpha: 0.05) : null,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(Icons.rocket_launch, color: Colors.purple, size: 20),
                    ),
                    title: Text(
                      loc.isBangla ? 'গ্যাস লাগবা সেন্ট্রাল রাইডার' : 'Request Gas Lagba Rider',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                    ),
                    subtitle: Text(
                      loc.isBangla
                          ? 'অর্ডারটি গ্যাস লাগবা অন-ডিমান্ড রাইডার পুলে যুক্ত হবে।'
                          : 'Broadcast to Gas Lagba on-demand platform riders.',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    trailing: Radio<String>(
                      value: 'PLATFORM_RIDER',
                      groupValue: selectedMode,
                      activeColor: Colors.purple,
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    onTap: () => setModalState(() => selectedMode = 'PLATFORM_RIDER'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(loc.tr('cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMode == 'PLATFORM_RIDER' ? Colors.purple : AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (selectedMode == 'STAFF_RIDER' && (selectedRiderId == null || riderProv.riders.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an in-house staff rider or choose another option.')),
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  final orderProv = context.read<VendorOrderProvider>();
                  final ok = await orderProv.dispatchOrder(
                    order.id,
                    riderId: selectedMode == 'STAFF_RIDER' ? selectedRiderId : null,
                    deliveryType: selectedMode,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? (selectedMode == 'PLATFORM_RIDER'
                                  ? 'Gas Lagba rider requested! Broadcasted to platform.'
                                  : 'Order dispatched successfully!')
                              : (orderProv.error ?? 'Failed to dispatch order'),
                        ),
                        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                      ),
                    );
                  }
                },
                child: Text(
                  selectedMode == 'PLATFORM_RIDER'
                      ? (loc.isBangla ? 'রিকোয়েস্ট পাঠান' : 'Request Rider')
                      : loc.tr('markDispatched'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final orderProv = context.watch<VendorOrderProvider>();
    final order = orderProv.currentOrder;

    if (orderProv.isLoading && order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('#${order.orderNumber}'),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrderDetails(widget.orderId),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.branchName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${DateFormat('dd MMM, yyyy - hh:mm a').format(order.createdAt)}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // Cancellation Request Card
              if (order.hasCancellationRequest) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB3B3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
                          const SizedBox(width: 8),
                          Text(
                            loc.tr('cancelRequestTitle'),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: ${order.cancellationRequestReason ?? 'Customer requested cancellation'}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF990000)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: loc.tr('approveCancel'),
                              backgroundColor: AppTheme.danger,
                              height: 40,
                              onPressed: () => orderProv.decideCancellationRequest(order.id, true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              text: loc.tr('rejectCancel'),
                              isOutlined: true,
                              textColor: AppTheme.danger,
                              height: 40,
                              onPressed: () => orderProv.decideCancellationRequest(order.id, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Customer Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.customerPhone,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (order.customerPhone.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppTheme.success),
                          onPressed: () => launchUrl(Uri.parse('tel:${order.customerPhone}')),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Delivery Address & Schedule
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              order.deliveryAddressText,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            order.deliveryMode == 'SCHEDULED' && order.deliverySlotFormatted != null
                                ? 'Scheduled: ${order.deliverySlotFormatted}'
                                : 'Delivery Mode: ASAP',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.payment, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Payment Method: ${order.paymentMethod}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Items Snapshot
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'অর্ডারের পণ্যসমূহ' : 'Ordered Cylinders',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.productName} (${item.variantName})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      '${item.quantity} x ${item.unitPrice.format()}${item.depositPaisa > 0 ? ' + Dep. ${item.deposit.format()}' : ''}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              MoneyText(money: item.lineTotal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          MoneyText(money: order.subtotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (order.depositTotalPaisa > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cylinder Deposit', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
                            MoneyText(money: order.depositTotal, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          MoneyText(money: order.deliveryFee, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          MoneyText(
                            money: order.total,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons by State
              if (order.status == VendorOrderStatus.pending) ...[
                CustomButton(
                  text: loc.tr('accept'),
                  backgroundColor: AppTheme.primary,
                  onPressed: () => orderProv.acceptOrder(order.id),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: loc.tr('reject'),
                  isOutlined: true,
                  backgroundColor: AppTheme.danger,
                  textColor: AppTheme.danger,
                  onPressed: () => _showRejectDialog(order),
                ),
              ] else if (order.status == VendorOrderStatus.accepted) ...[
                CustomButton(
                  text: loc.tr('markPreparing'),
                  backgroundColor: const Color(0xFF4338CA),
                  onPressed: () => orderProv.startPreparing(order.id),
                ),
              ] else if (order.status == VendorOrderStatus.preparing) ...[
                CustomButton(
                  text: loc.tr('markReady'),
                  backgroundColor: const Color(0xFF6D28D9),
                  onPressed: () => orderProv.markReady(order.id),
                ),
              ] else if (order.status == VendorOrderStatus.ready) ...[
                CustomButton(
                  text: loc.tr('markDispatched'),
                  backgroundColor: AppTheme.accent,
                  onPressed: () => _showDispatchDialog(order),
                ),
              ] else if (order.status == VendorOrderStatus.outForDelivery) ...[
                CustomButton(
                  text: loc.tr('markDelivered'),
                  backgroundColor: AppTheme.success,
                  onPressed: () => orderProv.markDelivered(order.id, codCollected: true),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
