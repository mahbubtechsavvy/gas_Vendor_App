import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/branch_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../providers/subscription_provider.dart';
import '../dashboard/vendor_main_navigation_shell.dart';
import '../subscription/subscription_screen.dart';
import 'email_entry_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isChecking = false;

  void _checkStatus() async {
    setState(() => _isChecking = true);
    final auth = context.read<VendorAuthProvider>();
    final branchProv = context.read<BranchProvider>();

    await auth.fetchProfiles();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (auth.vendorProfile?.status.isApproved == true) {
      await branchProv.fetchBranches();
      if (!mounted) return;
      final subProv = context.read<SubscriptionProvider>();
      await subProv.fetchSubscriptionData();
      if (!mounted) return;

      if (subProv.currentSubscription?.isActive == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VendorMainNavigationShell()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SubscriptionScreen(canGoBack: false)),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleProvider>().isBangla
                ? 'আপনার আবেদনটি এখনও পর্যালোচনাধীন রয়েছে।'
                : 'Your application is still under review by our admin team.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final vendor = auth.vendorProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 72,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.isBangla ? 'আবেদন পর্যালোচনাধীন রয়েছে' : 'Application Under Review',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  loc.isBangla
                      ? 'আপনার ভেন্ডর পার্টনার আবেদনটি গ্যাস লাগবে অ্যাডমিন টিম যাচাই করছে। অনুমোদন সম্পন্ন হলে অ্যাপের সম্পূর্ণ অ্যাক্সেস পেয়ে যাবেন।'
                      : 'Our operations team is verifying your business documents. You will get full access once approved.',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                if (vendor != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.businessName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Trade License: ${vendor.tradeLicenseNo}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'Email: ${vendor.contactEmail}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                CustomButton(
                  text: loc.isBangla ? 'স্ট্যাটাস যাচাই করুন' : 'Refresh Status',
                  icon: Icons.refresh,
                  isLoading: _isChecking,
                  onPressed: _checkStatus,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: loc.isBangla ? 'সাপোর্ট হেল্পলাইনে কল করুন' : 'Contact Support',
                  icon: Icons.headset_mic_outlined,
                  isOutlined: true,
                  onPressed: () => launchUrl(Uri.parse('tel:+8801700000000')),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    loc.tr('logout'),
                    style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
