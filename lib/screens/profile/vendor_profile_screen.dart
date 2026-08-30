import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vendor_auth_provider.dart';
import '../auth/email_entry_screen.dart';
import '../payouts/vendor_payout_methods_screen.dart';
import '../products/products_screen.dart';
import '../rider/rider_home_screen.dart';
import '../subscription/subscription_screen.dart';
import 'vendor_edit_profile_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    final auth = context.read<VendorAuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.tr('logout')),
        content: Text(loc.tr('logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(loc.tr('logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final vendor = auth.vendorProfile;
    final staff = auth.staffProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: loc.isBangla ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VendorEditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vendor Business Card with Unique ID
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: ClipOval(
                            child:
                                vendor?.logoUrl != null &&
                                    vendor!.logoUrl!.isNotEmpty
                                ? (vendor.logoUrl!.startsWith('data:')
                                      ? Image.memory(
                                          base64Decode(
                                            vendor.logoUrl!.split(',').last,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.storefront,
                                                size: 36,
                                                color: AppTheme.primary,
                                              ),
                                        )
                                      : Image.network(
                                          vendor.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.storefront,
                                                size: 36,
                                                color: AppTheme.primary,
                                              ),
                                        ))
                                : const Icon(
                                    Icons.storefront,
                                    size: 36,
                                    color: AppTheme.primary,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor?.businessName ?? 'Vendor Partner',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                staff?.fullName ?? (staff?.email ?? ''),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  staff?.role.displayName ?? 'Staff',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (vendor?.uniqueCode != null) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: vendor.uniqueCode!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.isBangla
                                    ? 'ভেন্ডর আইডি কপি হয়েছে!'
                                    : 'Vendor ID #${vendor.uniqueCode} copied to clipboard!',
                              ),
                              backgroundColor: AppTheme.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fingerprint,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.isBangla
                                        ? 'ভেন্ডর আইডি:'
                                        : 'Vendor ID:',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '#${vendor!.uniqueCode}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    loc.isBangla ? 'কপি করুন' : 'Tap to copy',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Profile & Compliance Tile
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.badge_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'প্রোফাইল ও এনআইডি ভেরিফিকেশন'
                          : 'Edit Profile & NID Verification',
                    ),
                    subtitle: Text(
                      (vendor?.nidNo != null && vendor!.nidNo!.isNotEmpty)
                          ? (loc.isBangla
                                ? 'NID: ${vendor.nidNo}'
                                : 'NID No: ${vendor.nidNo}')
                          : (loc.isBangla
                                ? '⚠ এনআইডি কার্ড জমা দিন'
                                : '⚠ Submit mandatory NID Card'),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            (vendor?.nidNo != null && vendor!.nidNo!.isNotEmpty)
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VendorEditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Store Management: Products & Receiving Accounts
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.propane_tank_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'আমার সিলিন্ডার ও প্রোডাক্টসমূহ'
                          : 'My Cylinder Products & Catalogue',
                    ),
                    subtitle: Text(
                      loc.isBangla
                          ? 'সিলিন্ডার যোগ করুন ও ভেরিফিকেশন স্ট্যাটাস দেখুন'
                          : 'Manage products & view admin approval status',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'পেমেন্ট রিসিভিং একাউন্টস'
                          : 'Payment Receiving Accounts',
                    ),
                    subtitle: Text(
                      loc.isBangla
                          ? 'বিকাশ, নগদ, রকেট ও ব্যাংক একাউন্ট ভেরিফিকেশন'
                          : 'bKash, Nagad, Rocket & Bank payout accounts',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VendorPayoutMethodsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.electric_moped_outlined,
                      color: Colors.purple,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'রাইডার ডেলিভারি মোড (Rider Hub)'
                          : 'Rider Delivery Mode',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    subtitle: Text(
                      loc.isBangla
                          ? 'সরাসরি পিকআপ, গ্রাহকের লোকেশন ম্যাপ ও ডেলিভারি মোডে যান'
                          : 'Switch to Rider Hub for pickups, map navigation & OTP deliveries',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RiderHomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Preferences
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'সাবস্ক্রিপশন ও প্ল্যান'
                          : 'Subscription & Plans',
                    ),
                    subtitle: Text(
                      loc.isBangla
                          ? 'প্ল্যান রিনিউ বা আপগ্রেড করুন'
                          : 'Manage or upgrade partner plan',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const SubscriptionScreen(canGoBack: true),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla
                          ? 'ভাষা পরিবর্তন (Language)'
                          : 'Language (ভাষা)',
                    ),
                    subtitle: Text(loc.isBangla ? 'বাংলা (Bangla)' : 'English'),
                    trailing: Switch(
                      value: loc.isBangla,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (val) {
                        loc.setLocale(val ? 'bn' : 'en');
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.headset_mic_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('support')),
                    subtitle: const Text('24/7 Helpline: 01644-274016'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () => launchUrl(Uri.parse('tel:+8801644274016')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Legal & About
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla ? 'ভেন্ডর শর্তাবলী' : 'Vendor Partner Terms',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      loc.isBangla ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFCCCC)),
              ),
              tileColor: AppTheme.dangerLight,
              leading: const Icon(Icons.logout, color: AppTheme.danger),
              title: Text(
                loc.tr('logout'),
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
