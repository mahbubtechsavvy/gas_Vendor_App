import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/vendor_main_navigation_shell.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool canGoBack;

  const SubscriptionScreen({super.key, this.canGoBack = false});

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

  void _showPaymentModal(SubscriptionPlanModel plan) {
    final loc = context.read<LocaleProvider>();
    final vendor = context.read<VendorAuthProvider>().vendorProfile;
    final trxIdController = TextEditingController();
    final senderPhoneController = TextEditingController(text: vendor?.contactPhone ?? '');
    String selectedMethod = 'BKASH';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final subProv = context.read<SubscriptionProvider>();
          String accountNumber = subProv.bkashNumber;
          if (selectedMethod == 'NAGAD') accountNumber = subProv.nagadNumber;
          if (selectedMethod == 'ROCKET') accountNumber = subProv.rocketNumber;
          if (selectedMethod == 'BANK') accountNumber = subProv.bankDetails;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      loc.isBangla
                          ? '${plan.nameBn.isNotEmpty ? plan.nameBn : plan.name} - পেমেন্ট নির্দেশিকা'
                          : 'Payment for ${plan.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.isBangla
                          ? 'নির্ধারিত ফি: ৳${(plan.feeMonthlyPaisa / 100).toStringAsFixed(0)} (${plan.durationDays} দিন)'
                          : 'Fee: ৳${(plan.feeMonthlyPaisa / 100).toStringAsFixed(0)} (${plan.durationDays} days)',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Chips
                    Text(
                      loc.isBangla ? 'পেমেন্ট মেথড নির্বাচন করুন:' : 'Select Payment Channel:',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMethodChip(
                          label: 'bKash',
                          value: 'BKASH',
                          color: const Color(0xFFE2136E),
                          selected: selectedMethod == 'BKASH',
                          onTap: () => setModalState(() => selectedMethod = 'BKASH'),
                        ),
                        const SizedBox(width: 8),
                        _buildMethodChip(
                          label: 'Nagad',
                          value: 'NAGAD',
                          color: const Color(0xFFF7941D),
                          selected: selectedMethod == 'NAGAD',
                          onTap: () => setModalState(() => selectedMethod = 'NAGAD'),
                        ),
                        const SizedBox(width: 8),
                        _buildMethodChip(
                          label: 'Rocket',
                          value: 'ROCKET',
                          color: const Color(0xFF8C3494),
                          selected: selectedMethod == 'ROCKET',
                          onTap: () => setModalState(() => selectedMethod = 'ROCKET'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instructions Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                loc.isBangla ? 'টাকা পাঠানোর নিয়ম:' : 'Payment Instructions:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9A3412),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.isBangla
                                ? '১. আপনার $selectedMethod অ্যাপে গিয়ে Send Money অপশন চাপুন।\n'
                                  '২. নিচে দেওয়া গ্যাস লাগবে অফিশিয়াল নাম্বারে ৳${(plan.feeMonthlyPaisa / 100).toStringAsFixed(0)} পাঠান।\n'
                                  '৩. টাকা পাঠানোর পর পাওয়া TrxID নিচে লিখুন।'
                                : '1. Open your $selectedMethod app and choose Send Money.\n'
                                  '2. Send ৳${(plan.feeMonthlyPaisa / 100).toStringAsFixed(0)} to the official Gas Lagba number below.\n'
                                  '3. Copy the TrxID and paste it below.',
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF431407)),
                          ),
                          const SizedBox(height: 12),
                          // Copy Number Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$selectedMethod Number (Send Money)',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      accountNumber,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: AppTheme.primary, size: 20),
                                  tooltip: 'Copy Number',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: accountNumber));
                                    ScaffoldMessenger.of(modalCtx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          loc.isBangla ? 'নাম্বার কপি করা হয়েছে!' : 'Number copied to clipboard!',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sender Phone Field
                    TextFormField(
                      controller: senderPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.isBangla ? 'যে নাম্বার থেকে টাকা পাঠিয়েছেন' : 'Sender Mobile Number',
                        hintText: '018XXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_android),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (loc.isBangla ? 'প্রেরক নম্বর প্রয়োজন' : 'Sender phone is required')
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Transaction ID Field
                    TextFormField(
                      controller: trxIdController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: loc.isBangla ? 'ট্রানজেকশন আইডি (TrxID)' : 'Transaction ID (TrxID)',
                        hintText: 'e.g. BL892KJH1',
                        prefixIcon: const Icon(Icons.receipt_long_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (loc.isBangla ? 'TrxID দিন' : 'TrxID is required')
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    CustomButton(
                      text: loc.isBangla ? 'পেমেন্ট তথ্য সাবমিট করুন' : 'Submit Payment for Verification',
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);

                        final subProv = context.read<SubscriptionProvider>();
                        final success = await subProv.subscribeAndSubmitPayment(
                          planKey: plan.code,
                          method: selectedMethod,
                          senderPhone: senderPhoneController.text.trim(),
                          transactionRef: trxIdController.text.trim(),
                          amountPaisa: plan.feeMonthlyPaisa,
                        );

                        if (!mounted) return;

                        if (success) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dCtx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.success, size: 28),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loc.isBangla ? 'পেমেন্ট জমা হয়েছে' : 'Payment Submitted',
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                loc.isBangla
                                    ? 'আপনার পেমেন্ট রিকোয়েস্ট সফলভাবে জমা হয়েছে। অ্যাডমিন টিম TrxID যাচাই সম্পন্ন করলেই আপনার অ্যাকাউন্ট সম্পূর্ণ সক্রিয় হয়ে যাবে।'
                                    : 'Your payment proof has been submitted. Our admin team will verify your TrxID shortly to activate full access.',
                                style: const TextStyle(fontSize: 14),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dCtx);
                                    if (mounted) {
                                      context.read<SubscriptionProvider>().fetchSubscriptionData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(loc.isBangla ? 'ঠিক আছে' : 'OK', style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        } else if (subProv.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(subProv.error!),
                              backgroundColor: AppTheme.danger,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodChip({
    required String label,
    required String value,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: selected ? color : Colors.grey.shade700,
              ),
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
        title: Text(loc.isBangla ? 'ভেন্ডর সাবস্ক্রিপশন প্ল্যান' : 'Vendor Partner Plans'),
        automaticallyImplyLeading: widget.canGoBack,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => subProv.fetchSubscriptionData(),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: subProv.isLoading && subProv.plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => subProv.fetchSubscriptionData(),
              color: AppTheme.primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Banner
                    if (sub != null)
                      _buildCurrentStatusCard(sub, loc)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFF2563EB), size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.isBangla ? 'প্ল্যান নির্বাচন করুন' : 'Choose a Subscription Plan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.isBangla
                                        ? 'অ্যাপের মাধ্যমে সিলিন্ডার অর্ডার গ্রহণ করতে নিচের যে কোনো একটি প্ল্যান সক্রিয় করুন।'
                                        : 'Select a plan below to activate order receiving and selling.',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      loc.isBangla ? 'আমাদের পার্টনার প্ল্যানসমূহ' : 'Available Subscription Packages',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // Render 3 Plans
                    ...subProv.plans.map((plan) => _buildPlanCard(plan, sub, loc)),

                    const SizedBox(height: 20),

                    // If active, show go to dashboard button
                    if (sub?.isActive == true)
                      CustomButton(
                        text: loc.isBangla ? 'ড্যাশবোর্ডে প্রবেশ করুন' : 'Go to Vendor Dashboard',
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const VendorMainNavigationShell()),
                            (route) => false,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentStatusCard(VendorSubscriptionModel sub, LocaleProvider loc) {
    final isActive = sub.isActive;
    return Card(
      color: isActive ? const Color(0xFF0F172A) : const Color(0xFF991B1B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.isBangla ? 'বর্তমান সাবস্ক্রিপশন স্ট্যাটাস' : 'Subscription Status',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.success : Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sub.status,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sub.planName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.pending_actions,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive
                      ? '${loc.tr('daysRemaining')}: ${sub.daysRemaining} days'
                      : (loc.isBangla
                          ? 'পেমেন্ট ভেরিফিকেশন বা রিনিউ প্রয়োজন'
                          : 'Payment verification / Renewal required'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlanModel plan,
    VendorSubscriptionModel? currentSub,
    LocaleProvider loc,
  ) {
    final isVIP = plan.code == 'PREMIUM_ANNUAL';
    final isHalfYear = plan.code == 'HALF_YEARLY';
    final isCurrent = currentSub?.planCode == plan.code && currentSub?.isActive == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isVIP
            ? const BorderSide(color: AppTheme.primary, width: 2)
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla && plan.nameBn.isNotEmpty ? plan.nameBn : plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        '${plan.durationDays} ${loc.isBangla ? 'দিন মেয়াদ' : 'Days Validity'}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isVIP)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BEST VALUE ⭐',
                      style: TextStyle(color: Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (isHalfYear)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'POPULAR 🔥',
                      style: TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Price Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '৳${(plan.feeMonthlyPaisa / 100).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  ' / ${plan.durationDays == 30 ? (loc.isBangla ? 'মাস' : 'month') : '${plan.durationDays} ${loc.isBangla ? 'দিন' : 'days'}'}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Feature checklist
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFeatureLabel(f, loc.isBangla),
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subscribe / Pay Button
            CustomButton(
              text: isCurrent
                  ? (loc.isBangla ? 'বর্তমান প্ল্যান' : 'Current Active Plan')
                  : (loc.isBangla ? 'সাবস্ক্রাইব ও পেমেন্ট করুন' : 'Subscribe & Pay'),
              isOutlined: isCurrent,
              onPressed: isCurrent ? null : () => _showPaymentModal(plan),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureLabel(String key, bool isBangla) {
    switch (key) {
      case 'full_app_access':
        return isBangla ? 'সম্পূর্ণ ভেন্ডর অ্যাপ অ্যাক্সেস' : 'Full Vendor App Access';
      case 'support_24_7':
        return isBangla ? '২৪/৭ সাপোর্ট ও সহায়তা' : '24/7 Priority Support';
      case 'monthly_reports':
        return isBangla ? 'মাসিক বিক্রয় ও হিসাব রিপোর্ট' : 'Monthly Sales Analytics';
      case 'yearly_reports':
        return isBangla ? 'বার্ষিক হিসাব ও ট্যাক্স রিপোর্ট' : 'Annual Audit & Tax Reports';
      case 'event_invitations':
        return isBangla ? 'গ্যাস লাগবে ডিলার মিটআপ আমন্ত্রণ' : 'Exclusive Dealer Meetups';
      case 'free_marketing':
        return isBangla ? 'অ্যাপে প্রায়োরিটি লিস্টিং ও প্রচার' : 'Featured App Promotion';
      case 'community_promotion':
        return isBangla ? 'কমিউনিটি প্রচার ও কাস্টমার কানেক্ট' : 'Community Promotion';
      case 'vip_membership':
        return isBangla ? 'ভিআইপি মেম্বারশিপ ব্যাজ' : 'VIP Partner Badge';
      case 'vendor_id_card':
        return isBangla ? 'অফিশিয়াল ভেন্ডর আইডি কার্ড' : 'Official Vendor ID Card';
      case 'ads_free':
        return isBangla ? 'বিজ্ঞাপন মুক্ত অভিজ্ঞতা' : '100% Ad-Free Experience';
      default:
        return key.replaceAll('_', ' ');
    }
  }
}
