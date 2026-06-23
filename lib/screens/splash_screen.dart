import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/access_control_service.dart';
import 'dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndAccess();
    });
  }

  Future<void> _checkAuthAndAccess() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check login status
    await authProvider.checkLoginStatus();

    // Wait for splash display
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate based on auth and access status
    if (authProvider.isLoggedIn) {
      // Check access level from API
      final accessInfo = await AccessControlService.checkAccess();

      if (!mounted) return;

      if (accessInfo != null) {
        switch (accessInfo.accessLevel) {
          case AccessLevel.profileOnly:
            // Profile incomplete - go to profile tab only
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(
                  initialTab: 3, // Profile tab
                  profileOnlyMode: true,
                ),
              ),
            );
            _showProfileIncompleteMessage();
            break;
          case AccessLevel.subscriptionOnly:
            // Profile complete but no subscription
            Navigator.pushReplacementNamed(context, '/subscription');
            break;
          case AccessLevel.full:
            // Full access
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
        }
      } else {
        // API failed - check local profile completion
        final vendor = authProvider.vendor;
        if (vendor != null) {
          // Calculate local profile completion
          final completion = _calculateProfileCompletion(vendor);
          if (completion < 100) {
            // Profile incomplete
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(
                  initialTab: 3, // Profile tab
                  profileOnlyMode: true,
                ),
              ),
            );
            _showProfileIncompleteMessage();
          } else {
            // Profile complete - go to dashboard
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          // Fallback to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  int _calculateProfileCompletion(dynamic vendor) {
    int completion = 0;

    // Check each required field
    if (vendor.profileImage != null && vendor.profileImage.isNotEmpty) {
      completion += 20;
    }
    if (vendor.name.isNotEmpty) {
      completion += 10;
    }
    if (vendor.mobile.isNotEmpty) {
      completion += 10;
    }
    if (vendor.email != null && vendor.email.isNotEmpty) {
      completion += 10;
    }
    if (vendor.businessName != null && vendor.businessName.isNotEmpty) {
      completion += 15;
    }
    if (vendor.shopAddress != null && vendor.shopAddress.isNotEmpty) {
      completion += 15;
    }
    if (vendor.businessType != null && vendor.businessType.isNotEmpty) {
      completion += 10;
    }
    if (vendor.nid != null && vendor.nid.isNotEmpty) {
      completion += 10;
    }

    return completion;
  }

  void _showProfileIncompleteMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please complete your profile to access all features',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset('assets/images/Logo.svg', width: 120, height: 120),
            const SizedBox(height: 30),

            // Loading Indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Loading text
            const Text(
              'Loading...',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
