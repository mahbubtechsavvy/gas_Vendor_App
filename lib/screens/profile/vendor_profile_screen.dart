import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vendor_auth_provider.dart';
import '../auth/email_entry_screen.dart';
import '../subscription/subscription_screen.dart';

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vendor Business Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor?.businessName ?? 'Vendor Partner',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            staff?.fullName ?? (staff?.email ?? ''),
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              staff?.role.displayName ?? 'Staff',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Preferences
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined, color: AppTheme.primary),
                    title: Text(loc.isBangla ? 'সাবস্ক্রিপশন ও প্ল্যান' : 'Subscription & Plans'),
                    subtitle: Text(loc.isBangla ? 'প্ল্যান রিনিউ বা আপগ্রেড করুন' : 'Manage or upgrade partner plan'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen(canGoBack: true)),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primary),
                    title: Text(loc.isBangla ? 'ভাষা পরিবর্তন (Language)' : 'Language (ভাষা)'),
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
                    leading: const Icon(Icons.headset_mic_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('support')),
                    subtitle: const Text('24/7 Helpline: 01644-274016'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
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
                    leading: const Icon(Icons.description_outlined, color: AppTheme.primary),
                    title: Text(loc.isBangla ? 'ভেন্ডর শর্তাবলী' : 'Vendor Partner Terms'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primary),
                    title: Text(loc.isBangla ? 'গোপনীয়তা নীতি' : 'Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
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
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
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
