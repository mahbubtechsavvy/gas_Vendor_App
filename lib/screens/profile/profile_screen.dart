import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/verification_badge.dart';
import 'edit_profile_screen.dart';
import '../analytics/business_analytics_screen.dart';
import '../delivery_hours/branch_delivery_hours_screen.dart';
import '../subscription/subscription_screen.dart';
import '../support/support_screen.dart';
import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }

  Future<void> _refreshProfile() async {
    try {
      final vendorData = await ProfileService.getVendorProfile();
      if (mounted) {
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).updateVendorData(vendorData);
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final vendor = authProvider.vendor;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConfig.spaceLG),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spaceXL),
                  decoration: BoxDecoration(
                    color: ThemeConfig.cardWhite,
                    borderRadius: BorderRadius.circular(
                      ThemeConfig.radiusLarge,
                    ),
                    boxShadow: ThemeConfig.cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Avatar with verification badge
                      VerifiedProfileAvatar(
                        radius: 50,
                        imageUrl: vendor?.profileImage,
                        isVerified: vendor?.isVerified ?? false,
                      ),
                      const SizedBox(height: ThemeConfig.spaceLG),

                      // Owner Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Owner Name: ${vendor?.name ?? 'TAMIM HOSSEN'}',
                          style: ThemeConfig.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Shop Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Shop Name: ${vendor?.businessName ?? 'Tamim Gas Store'}',
                          style: ThemeConfig.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Vendor ID
                      Text(
                        'ID: ${vendor?.uniqueId ?? 'VD1458943O'}',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: ThemeConfig.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spaceLG),

                      // Edit Profile Link
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                profile: vendor?.toJson() ?? {},
                              ),
                            ),
                          );
                          if (result == true) {
                            _refreshProfile();
                          }
                        },
                        child: Text(
                          'Edit Profile',
                          style: ThemeConfig.bodyMedium.copyWith(
                            color: ThemeConfig.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: ThemeConfig.spaceXL),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Business Analytics',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessAnalyticsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: ThemeConfig.spaceMD),

                _buildMenuItem(
                  icon: Icons.access_time_outlined,
                  title: 'Delivery Hours',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BranchDeliveryHoursScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: ThemeConfig.spaceMD),

                _buildMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Subscription',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: ThemeConfig.spaceMD),

                _buildMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: ThemeConfig.spaceXL),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(authProvider),
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
                    child: Text('Log Out', style: ThemeConfig.buttonText),
                  ),
                ),

                const SizedBox(height: ThemeConfig.space2XL),

                // Community Section
                Text(
                  'COMMUNITY',
                  style: ThemeConfig.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: ThemeConfig.textSecondary,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spaceLG),

                // Social Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: Icons.facebook,
                      url: 'https://facebook.com',
                      onTap: () => _launchURL('https://facebook.com'),
                    ),
                    const SizedBox(width: ThemeConfig.spaceMD),
                    SocialIconButton(
                      icon: Icons.music_note,
                      url: 'https://tiktok.com',
                      onTap: () => _launchURL('https://tiktok.com'),
                    ),
                    const SizedBox(width: ThemeConfig.spaceMD),
                    SocialIconButton(
                      icon: Icons.close,
                      url: 'https://x.com',
                      onTap: () => _launchURL('https://x.com'),
                    ),
                    const SizedBox(width: ThemeConfig.spaceMD),
                    SocialIconButton(
                      icon: Icons.business,
                      url: 'https://linkedin.com',
                      onTap: () => _launchURL('https://linkedin.com'),
                    ),
                  ],
                ),

                const SizedBox(height: ThemeConfig.space2XL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        decoration: BoxDecoration(
          color: ThemeConfig.cardWhite,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
          border: Border.all(color: ThemeConfig.borderColor),
          boxShadow: ThemeConfig.cardShadow,
        ),
        child: Row(
          children: [
            Icon(icon, color: ThemeConfig.textPrimary, size: 24),
            const SizedBox(width: ThemeConfig.spaceLG),
            Expanded(
              child: Text(
                title,
                style: ThemeConfig.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: ThemeConfig.textLight),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.statusDeclined,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }
}
