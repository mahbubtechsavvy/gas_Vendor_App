import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/branch_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/vendor_main_navigation_shell.dart';
import '../subscription/subscription_screen.dart';
import 'pending_approval_screen.dart';
import 'vendor_register_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<VendorAuthProvider>();
    final branchProv = context.read<BranchProvider>();
    final otp = _otpController.text.trim();

    final success = await auth.verifyOtp(otp);
    if (!mounted) return;

    if (success) {
      if (auth.vendorProfile == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VendorRegisterScreen()),
          (route) => false,
        );
      } else if (auth.vendorProfile?.status.isPending == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          (route) => false,
        );
      } else {
        await branchProv.fetchBranches();
        if (!mounted) return;
        final subProv = context.read<SubscriptionProvider>();
        await subProv.fetchSubscriptionData();
        if (!mounted) return;
        if (subProv.currentSubscription?.isActive == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const VendorMainNavigationShell(),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const SubscriptionScreen(canGoBack: false),
            ),
            (route) => false,
          );
        }
      }
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.danger),
      );
    }
  }

  void _resend() async {
    if (_secondsRemaining > 0) return;
    final auth = context.read<VendorAuthProvider>();
    if (auth.pendingEmail == null) return;
    final success = await auth.requestOtp(auth.pendingEmail!);
    if (!mounted) return;
    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleProvider>().isBangla
                ? 'নতুন ৮-সংখ্যার লগইন কোড পাঠানো হয়েছে।'
                : 'A new 8-digit verification code has been sent.',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final email = auth.pendingEmail ?? 'your email';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6600).withValues(alpha: 0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 38,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    loc.isBangla ? 'ভেন্ডর ওটিপি যাচাইকরণ' : 'Vendor Verification',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Email Chip (Responsive with Flexible to prevent overflow)
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.business, size: 14, color: Color(0xFFFF6600)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                loc.isBangla ? 'বদলান' : 'Change',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Verification Card
                  Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              loc.isBangla ? '৮-সংখ্যার কোড' : '8-DIGIT CODE',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_secondsRemaining > 0)
                              Text(
                                loc.isBangla
                                    ? '${_secondsRemaining} সেকেন্ড বাকি'
                                    : 'Resend in ${_secondsRemaining}s',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF6600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Monospace OTP input field (Supports 8-digit and 6-digit codes)
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 8,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade300,
                              letterSpacing: 6,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFFF6600), width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || (val.trim().length != 8 && val.trim().length != 6)) {
                              return loc.isBangla ? '৮-সংখ্যার ওটিপি কোড লিখুন' : 'Enter the complete 8-digit code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        CustomButton(
                          text: loc.tr('verifyOtp'),
                          isLoading: auth.isLoading,
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _verify,
                        ),
                        const SizedBox(height: 14),

                        Center(
                          child: TextButton(
                            onPressed: _secondsRemaining == 0 ? _resend : null,
                            child: Text(
                              loc.tr('resendOtp'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _secondsRemaining == 0
                                    ? const Color(0xFFFF6600)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
