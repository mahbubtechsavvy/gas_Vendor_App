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

  void _showCompleteDeliveryDialog(VendorOrderModel order) {
    final loc = context.read<LocaleProvider>();
    final otpController = TextEditingController();
    final isCod = order.paymentMethod.toUpperCase() == 'COD';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.success),
            const SizedBox(width: 8),
            Text(
              loc.isBangla ? 'ডেলিভারি সম্পন্ন নিশ্চিতকরণ' : 'Confirm Handover & Delivery',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCod ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCod ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCod ? Icons.payments_outlined : Icons.verified_outlined,
                    color: isCod ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCod
                              ? (loc.isBangla ? 'ক্যাশ অন ডেলিভারি (আদায়যোগ্য)' : 'Cash to Collect (COD)')
                              : (loc.isBangla ? 'ডিজিটাল পেমেন্ট পরিশোধিত' : 'Paid in Full (Digital)'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCod ? const Color(0xFF92400E) : const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCod ? order.total.format() : 'Paid Online',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCod ? const Color(0xFFB45309) : const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.isBangla ? 'গ্রাহকের ৪-ডিজিটের হ্যান্ডওভার ওটিপি কোড:' : 'Customer 4-digit Handover OTP:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final orderProv = context.read<VendorOrderProvider>();
              await orderProv.markDelivered(
                order.id,
                codCollected: true,
                otp: otpController.text.trim(),
              );
            },
            child: Text(loc.isBangla ? 'ডেলিভারি সম্পন্ন করুন' : 'Confirm Delivered'),
          ),
        ],
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
              ] else if (order.status == VendorOrderStatus.accepted ||
                  order.status == VendorOrderStatus.preparing ||
                  order.status == VendorOrderStatus.ready) ...[
                CustomButton(
                  text: loc.isBangla ? '🚀 ডেলিভারির জন্য বের হোন (নিজস্ব ডেলিভারি)' : '🚀 Start Delivery (I am Delivering)',
                  backgroundColor: AppTheme.accent,
                  onPressed: () => orderProv.dispatchOrder(order.id, deliveryType: 'SELF'),
                ),
              ] else if (order.status == VendorOrderStatus.outForDelivery) ...[
                CustomButton(
                  text: loc.isBangla ? '✅ ডেলিভারি সম্পন্ন ও ওটিপি দিন' : '✅ Complete Delivery (Enter OTP)',
                  backgroundColor: AppTheme.success,
                  onPressed: () => _showCompleteDeliveryDialog(order),
                ),
              ] else if (order.status == VendorOrderStatus.delivered) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF16A34A), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        loc.isBangla ? 'অর্ডারটি সফলভাবে ডেলিভারি সম্পন্ন হয়েছে' : 'Order Delivered Successfully',
                        style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
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
