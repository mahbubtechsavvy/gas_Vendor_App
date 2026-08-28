import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().fetchSubscriptionData();
    });
  }

  void _showRenewModal(SubscriptionPlanModel plan) {
    final loc = context.read<LocaleProvider>();
    final vendorId = context.read<VendorAuthProvider>().vendorProfile?.id ?? '';
    final trxIdController = TextEditingController();
    String method = 'bKash';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${loc.tr('renewPlan')} - ${plan.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monthly Fee: ${plan.feeMonthly.format()}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Payment Channel'),
                  items: const [
                    DropdownMenuItem(value: 'bKash', child: Text('bKash Merchant (017XXXXXXXX)')),
                    DropdownMenuItem(value: 'Nagad', child: Text('Nagad Merchant (018XXXXXXXX)')),
                    DropdownMenuItem(value: 'BANK', child: Text('City Bank A/C: 1102938475')),
                  ],
                  onChanged: (val) => setModalState(() => method = val ?? 'bKash'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: trxIdController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction ID (TrxID)',
                    hintText: 'e.g. 9J87AKL12P',
                    prefixIcon: Icon(Icons.receipt_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'TrxID is required' : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: loc.isBangla ? 'পেমেন্ট ভেরিফিকেশন পাঠান' : 'Submit Verification',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final subProv = context.read<SubscriptionProvider>();
                    final success = await subProv.submitManualPayment(
                      vendorId: vendorId,
                      planCode: plan.code,
                      transactionId: trxIdController.text.trim(),
                      paymentMethod: method,
                      amountPaisa: plan.feeMonthlyPaisa,
                    );
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.isBangla
                                ? 'পেমেন্ট সফলভাবে জমা হয়েছে। অ্যাডমিন পর্যালোচনার পর প্ল্যান সক্রিয় হবে।'
                                : 'Payment submitted. Plan will be active upon admin confirmation.',
                          ),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final subProv = context.watch<SubscriptionProvider>();
    final sub = subProv.currentSubscription;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('subscription')),
      ),
      body: RefreshIndicator(
        onRefresh: () => subProv.fetchSubscriptionData(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Subscription Status Card
              Card(
                color: sub?.isActive == true ? const Color(0xFF0F172A) : AppTheme.danger,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.tr('activePlan'),
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sub?.isActive == true ? AppTheme.success : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              sub?.status ?? 'ACTIVE',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sub?.planName ?? 'Standard Partner',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${loc.tr('daysRemaining')}: ${sub?.daysRemaining ?? 30} days',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                loc.isBangla ? 'প্যাকেজসমূহ' : 'Available Partner Plans',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              ...subProv.plans.map((plan) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              children: [
                                MoneyText(
                                  money: plan.feeMonthly,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                                ),
                                const Text('/mo', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Max ${plan.branchLimit} Branch(es) • ${plan.staffLimit} Staff Accounts',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        ...plan.features.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 16, color: AppTheme.success),
                                  const SizedBox(width: 6),
                                  Text(f, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: loc.tr('renewPlan'),
                          height: 40,
                          isOutlined: true,
                          onPressed: () => _showRenewModal(plan),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
