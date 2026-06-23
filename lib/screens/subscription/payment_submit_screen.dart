import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/subscription_service.dart';
import 'payment_success_screen.dart';

class PaymentSubmitScreen extends StatefulWidget {
  final int planId;
  final String planName;
  final double planPrice;
  final String promoCode;

  const PaymentSubmitScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.planPrice,
    this.promoCode = '',
  });

  @override
  State<PaymentSubmitScreen> createState() => _PaymentSubmitScreenState();
}

class _PaymentSubmitScreenState extends State<PaymentSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _bkashNumberController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _promoCodeController = TextEditingController();

  final String _bkashPaymentNumber = '01644274016';
  bool _isLoading = false;
  bool _isValidatingPromo = false;

  // Promo discount state (from server)
  double _discountAmount = 0;
  double _finalPrice = 0;
  String _discountLabel = '';
  bool _promoApplied = false;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.planPrice;
    _promoCodeController.text = widget.promoCode;
    _loadVendorInfo();
  }

  void _loadVendorInfo() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendor = authProvider.vendor;
    if (vendor != null) {
      _ownerNameController.text = vendor.name;
      _contractNumberController.text = vendor.mobile;
      _shopNameController.text = vendor.businessName ?? '';
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _contractNumberController.dispose();
    _shopNameController.dispose();
    _bkashNumberController.dispose();
    _transactionIdController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  /// Validate promo code via server API
  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isValidatingPromo = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorId = authProvider.vendor?.id ?? 0;

    final result = await SubscriptionService().validatePromo(
      code: code,
      planId: widget.planId,
      vendorId: vendorId,
    );

    if (mounted) {
      setState(() => _isValidatingPromo = false);

      if (result['success'] == true) {
        setState(() {
          _promoApplied = true;
          _discountAmount = (result['discount_amount'] as num).toDouble();
          _finalPrice = (result['final_price'] as num).toDouble();
          if (result['discount_type'] == 'percent') {
            _discountLabel =
                '-${(result['discount_value'] as num).toInt()}% off';
          } else {
            _discountLabel = '-৳${_discountAmount.toStringAsFixed(0)}';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Promo code applied!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _promoApplied = false;
          _discountAmount = 0;
          _finalPrice = widget.planPrice;
          _discountLabel = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid promo code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendor = authProvider.vendor;

      final vendorId = vendor?.id?.toString() ?? '1';
      final vendorUniqueId = vendor?.uniqueId ?? 'VD000001';

      final success = await SubscriptionService().submitPayment(
        vendorId: vendorId,
        vendorUniqueId: vendorUniqueId,
        ownerName: _ownerNameController.text,
        contractNumber: _contractNumberController.text,
        shopName: _shopNameController.text,
        bkashNumber: _bkashNumberController.text,
        transactionId: _transactionIdController.text,
        promoCode: _promoCodeController.text,
        planId: widget.planId,
        amount: _finalPrice,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentSuccessScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment submission failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyBkashNumber() {
    Clipboard.setData(ClipboardData(text: _bkashPaymentNumber));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('bKash number copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vendorId = authProvider.vendor?.uniqueId ?? 'VD00000000';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // bKash Payment Info Banner
              GestureDetector(
                onTap: _copyBkashNumber,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spaceLG,
                    vertical: ThemeConfig.spaceMD,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusFull),
                    border: Border.all(color: const Color(0xFFE91E63)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'only bkash sendmoney to: ',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: ThemeConfig.textPrimary,
                        ),
                      ),
                      Text(
                        _bkashPaymentNumber,
                        style: ThemeConfig.bodyMedium.copyWith(
                          color: ThemeConfig.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Plan Info Card
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spaceLG),
                decoration: BoxDecoration(
                  color: ThemeConfig.cardWhite,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
                  border: Border.all(color: ThemeConfig.primaryBlue, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConfig.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.planName,
                            style: ThemeConfig.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '৳${widget.planPrice.toStringAsFixed(0)}',
                          style: ThemeConfig.heading2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subscription Plan',
                      style: ThemeConfig.bodyMedium.copyWith(
                        color: ThemeConfig.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Form Fields
              _buildLabel('ID:'),
              _buildReadOnlyField(vendorId),

              _buildLabel('Owner Name:'),
              _buildTextField(
                controller: _ownerNameController,
                hint: 'Enter owner name',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              _buildLabel('*Owner Contract Number:', isRequired: true),
              _buildTextField(
                controller: _contractNumberController,
                hint: 'Enter contract number',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              _buildLabel('*Shop Name:', isRequired: true),
              _buildTextField(
                controller: _shopNameController,
                hint: 'Enter shop name',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              _buildLabel('*bkash Payment Number:', isRequired: true),
              _buildTextField(
                controller: _bkashNumberController,
                hint: 'Enter bKash number used for payment',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              _buildLabel('*Transaction ID:', isRequired: true),
              _buildTextField(
                controller: _transactionIdController,
                hint: 'Enter bKash transaction ID',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              _buildLabel('Promo Code:'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _promoCodeController,
                      hint: 'Enter promo code',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isValidatingPromo ? null : _applyPromoCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: _isValidatingPromo
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Apply'),
                  ),
                ],
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Price Summary
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spaceLG),
                decoration: BoxDecoration(
                  color: ThemeConfig.cardWhite,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                      widget.planName,
                      '৳ ${widget.planPrice.toStringAsFixed(0)} TK',
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Discount',
                      _promoApplied ? _discountLabel : '0',
                      valueColor: ThemeConfig.statusDelivered,
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow('VAT', '0'),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Total Pay',
                      '৳ ${_finalPrice.toStringAsFixed(0)} TK',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPayment,
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
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: ThemeConfig.buttonText.copyWith(fontSize: 18),
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

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: ThemeConfig.bodyMedium.copyWith(
          color: isRequired
              ? ThemeConfig.statusDeclined
              : ThemeConfig.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: ThemeConfig.bodyMedium),
          const Icon(Icons.lock, size: 18, color: ThemeConfig.textLight),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ThemeConfig.bodyMedium.copyWith(
          color: ThemeConfig.textLight,
        ),
        filled: true,
        fillColor: ThemeConfig.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
          borderSide: BorderSide(color: ThemeConfig.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
          borderSide: BorderSide(color: ThemeConfig.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
          borderSide: BorderSide(color: ThemeConfig.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? ThemeConfig.bodyLarge.copyWith(fontWeight: FontWeight.bold)
              : ThemeConfig.bodyMedium.copyWith(
                  color: ThemeConfig.textSecondary,
                ),
        ),
        const Text(':', style: TextStyle(color: ThemeConfig.textSecondary)),
        Text(
          value,
          style: isBold
              ? ThemeConfig.bodyLarge.copyWith(fontWeight: FontWeight.bold)
              : ThemeConfig.bodyMedium.copyWith(
                  color: valueColor ?? ThemeConfig.textPrimary,
                ),
        ),
      ],
    );
  }
}
