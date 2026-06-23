import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../config/theme_config.dart';
import '../../models/subscription_plan.dart';
import '../../models/vendor_subscription.dart';
import '../../services/subscription_service.dart';
import '../support/support_screen.dart';
import 'payment_submit_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();

  bool _isLoading = true;
  List<SubscriptionPlan> _plans = [];
  VendorSubscription? _vendorSub;
  int? _expandedPlanIndex;
  int? _selectedPlanIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey) ?? '';

      final results = await Future.wait([
        _subscriptionService.getPlans(),
        _subscriptionService.getVendorSubscription(token),
      ]);

      if (mounted) {
        setState(() {
          _plans = results[0] as List<SubscriptionPlan>;
          _vendorSub = results[1] as VendorSubscription?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$code" copied!'),
        backgroundColor: ThemeConfig.statusDelivered,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToPayment() {
    if (_selectedPlanIndex == null || _selectedPlanIndex! >= _plans.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a plan first'),
          backgroundColor: ThemeConfig.statusPending,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    final plan = _plans[_selectedPlanIndex!];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSubmitScreen(
          planId: plan.id,
          planName: plan.name,
          planPrice: plan.price,
          promoCode: plan.promoCode,
        ),
      ),
    );
  }

  void _showTermsDialog(String url) {
    if (url.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terms: $url'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Subscription', style: ThemeConfig.heading3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(ThemeConfig.spaceLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Subscription Status Card
                    // Show card for any non-none subscription status
                    if (_vendorSub != null && !_vendorSub!.isNone)
                      _buildStatusCard(),

                    // Expired/Pending warnings
                    if (_vendorSub != null && _vendorSub!.isExpired)
                      _buildExpiredWarning(),
                    if (_vendorSub != null && _vendorSub!.isPending)
                      _buildPendingBanner(),
                    if (_vendorSub == null || _vendorSub!.isNone)
                      _buildNewVendorBanner(),

                    const SizedBox(height: ThemeConfig.spaceXL),

                    // Plan Cards
                    ..._plans.asMap().entries.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      return _buildPlanCard(plan, index);
                    }),

                    const SizedBox(height: ThemeConfig.spaceXL),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeConfig.spaceLG,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConfig.radiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          'Pay',
                          style: ThemeConfig.buttonText.copyWith(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: ThemeConfig.spaceLG),

                    // Support Button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.smart_toy_outlined, size: 20),
                        label: const Text('SUPPORT'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeConfig.textPrimary,
                          side: const BorderSide(
                            color: ThemeConfig.borderColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConfig.radiusFull,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: ThemeConfig.space2XL),
                  ],
                ),
              ),
            ),
    );
  }

  // ==================== STATUS CARD ====================

  Widget _buildStatusCard() {
    final sub = _vendorSub!;
    final isActive = sub.isActive;
    final isExpired = sub.isExpired;

    // Colors per state: green=active, red=expired, orange=pending
    final statusColor = isActive
        ? const Color(0xFF22C55E)
        : isExpired
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final statusText = isActive
        ? 'Active'
        : isExpired
        ? 'Expired'
        : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConfig.spaceLG),
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: shop name row + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Shop Name', sub.shopName.isNotEmpty ? sub.shopName : '-'),
                    _buildInfoRow('ID', sub.vendorId.isNotEmpty ? sub.vendorId : '-'),
                    _buildInfoRow('Plan Name', sub.planName ?? '-'),
                    _buildInfoRow(
                      'Duration (Month)',
                      sub.durationMonths > 0 ? '${sub.durationMonths}' : '-',
                    ),
                    _buildInfoRow('Plan Expired', sub.planExpired ?? '-'),
                    _buildInfoRow(
                      'Plan Session Year',
                      sub.planSessionYear.isNotEmpty ? sub.planSessionYear : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeConfig.spaceMD),

          // Numbered month progress bar
          _buildMonthProgressBar(sub.monthsElapsed, sub.durationMonths, isExpired),

          const SizedBox(height: ThemeConfig.spaceSM),

          // Terms link
          GestureDetector(
            onTap: () => _showTermsDialog(''),
            child: Center(
              child: Text(
                'GAS LAGBE TERMS AND CONDITIONS',
                style: ThemeConfig.captionText.copyWith(
                  color: ThemeConfig.textLight,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Flat info row: "Label: Value" style matching the new UI design
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildMonthProgressBar(double elapsed, int total, [bool isExpired = false]) {
    final displayMonths = total > 0 ? total : 12;
    // For expired: all segments filled red; for active: filled=blue, unfilled=grey
    final filledColor = isExpired
        ? const Color(0xFFEF4444)
        : ThemeConfig.primaryBlue;
    final emptyColor = const Color(0xFFE5E7EB);

    return Column(
      children: [
        // Month number labels
        Row(
          children: List.generate(displayMonths, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 3),
        // Progress segments
        Row(
          children: List.generate(displayMonths, (i) {
            double fillRatio = 0.0;
            if (isExpired) {
              fillRatio = 1.0;
            } else {
              if (elapsed >= i + 1) {
                // Fully elapsed
                fillRatio = 1.0;
              } else if (elapsed > i && elapsed < i + 1) {
                // Partially elapsed month
                fillRatio = elapsed - i;
              }
            }

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: 6,
                decoration: BoxDecoration(
                  color: emptyColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.centerLeft,
                // The fractionally sized box creates the partial fill colored bar
                child: FractionallySizedBox(
                  widthFactor: fillRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: filledColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==================== WARNING BANNERS ====================

  Widget _buildExpiredWarning() {
    return Container(
      margin: const EdgeInsets.only(top: ThemeConfig.spaceLG),
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.statusDeclined.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(
          color: ThemeConfig.statusDeclined.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: ThemeConfig.statusDeclined,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your Plan Is Expired! Buy A New Plan To Active Again Your Gas Lagbe Vendor App',
              style: ThemeConfig.bodySmall.copyWith(
                color: ThemeConfig.statusDeclined,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      margin: const EdgeInsets.only(top: ThemeConfig.spaceLG),
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.statusPending.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(
          color: ThemeConfig.statusPending.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: ThemeConfig.statusPending,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payment verification is pending. Our team will verify within 6 hours.',
              style: ThemeConfig.bodySmall.copyWith(
                color: ThemeConfig.statusPending,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewVendorBanner() {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(
          color: ThemeConfig.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.waving_hand_rounded,
            color: ThemeConfig.primaryBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'New Vendor! Buy a Plan to Active Gas Lagbe Vendor App',
              style: ThemeConfig.bodySmall.copyWith(
                color: ThemeConfig.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PLAN CARDS ====================

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isExpanded = _expandedPlanIndex == index;
    final isSelected = _selectedPlanIndex == index;

    final bgColor = plan.getBoxColor();
    final borderColor = plan.getBorderColor();
    final txtColor = plan.getTextColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConfig.spaceMD),
      child: Column(
        children: [
          // Plan pill button
          GestureDetector(
            onTap: () {
              setState(() {
                if (_expandedPlanIndex == index) {
                  _expandedPlanIndex = null;
                } else {
                  _expandedPlanIndex = index;
                }
                _selectedPlanIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? bgColor : ThemeConfig.cardWhite,
                borderRadius: BorderRadius.circular(ThemeConfig.radiusFull),
                border: Border.all(
                  color: isSelected ? borderColor : ThemeConfig.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          plan.name,
                          style: ThemeConfig.bodyLarge.copyWith(
                            color: isSelected
                                ? txtColor
                                : ThemeConfig.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (plan.recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeConfig.statusDelivered,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: ThemeConfig.captionText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: isSelected ? txtColor : ThemeConfig.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded plan details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedPlanDetails(plan),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedPlanDetails(SubscriptionPlan plan) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.cardWhite,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan details header with crown icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConfig.statusPending.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: ThemeConfig.statusPending,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: ThemeConfig.heading3.copyWith(fontSize: 16),
                    ),
                    if (plan.description.isNotEmpty)
                      Text(plan.description, style: ThemeConfig.captionText),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeConfig.spaceLG),

          // Plan details rows
          _buildPlanDetailRow('Plan Name', plan.name),
          _buildPlanDetailRow('Price (৳)', '৳${plan.price.toStringAsFixed(0)}'),
          _buildPlanDetailRow(
            'Duration (Month)',
            plan.durationMonths > 0 ? '${plan.durationMonths}' : '-',
          ),
          _buildPlanDetailRow(
            'Plan Session Year',
            plan.planSessionYear.isNotEmpty ? plan.planSessionYear : '-',
          ),

          const SizedBox(height: ThemeConfig.spaceLG),

          // Plan title
          if (plan.planTitle.isNotEmpty) ...[
            Text(
              plan.planTitle,
              style: ThemeConfig.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: ThemeConfig.textPrimary,
              ),
            ),
            const SizedBox(height: ThemeConfig.spaceSM),
          ],

          // Features list with ✓/✗
          ...plan.features.asMap().entries.map((entry) {
            final featureIndex = entry.key;
            final feature = entry.value;
            final isIncluded = featureIndex < plan.featureIncluded.length
                ? plan.featureIncluded[featureIndex]
                : true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isIncluded
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isIncluded
                        ? ThemeConfig.statusDelivered
                        : ThemeConfig.textLight,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: ThemeConfig.bodySmall.copyWith(
                        color: isIncluded
                            ? ThemeConfig.textPrimary
                            : ThemeConfig.textLight,
                        decoration: isIncluded
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Promo code section
          if (plan.promoCode.isNotEmpty) ...[
            const SizedBox(height: ThemeConfig.spaceLG),
            const Divider(),
            const SizedBox(height: ThemeConfig.spaceSM),
            if (plan.promoText.isNotEmpty)
              Text(
                plan.promoText,
                style: ThemeConfig.bodySmall.copyWith(
                  color: ThemeConfig.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _copyPromoCode(plan.promoCode),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ThemeConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  border: Border.all(
                    color: ThemeConfig.borderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plan.promoCode,
                      style: ThemeConfig.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: ThemeConfig.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Terms link
          if (plan.termsLink.isNotEmpty) ...[
            const SizedBox(height: ThemeConfig.spaceMD),
            GestureDetector(
              onTap: () => _showTermsDialog(plan.termsLink),
              child: Text(
                'Terms & Conditions',
                style: ThemeConfig.captionText.copyWith(
                  color: ThemeConfig.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ThemeConfig.bodySmall.copyWith(
              color: ThemeConfig.textSecondary,
            ),
          ),
          Text(
            ': $value',
            style: ThemeConfig.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
