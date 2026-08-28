import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/i18n/locale_provider.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/branch_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payout_provider.dart';
import 'providers/rider_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/vendor_auth_provider.dart';
import 'providers/vendor_order_provider.dart';
import 'screens/auth/email_entry_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/auth/pending_approval_screen.dart';
import 'screens/auth/vendor_register_screen.dart';
import 'screens/dashboard/vendor_main_navigation_shell.dart';
import 'screens/delivery_hours/branch_delivery_hours_screen.dart';
import 'screens/inventory/branch_inventory_screen.dart';
import 'screens/notifications/vendor_notifications_screen.dart';
import 'screens/order/vendor_orders_screen.dart';
import 'screens/payouts/payout_ledger_screen.dart';
import 'screens/profile/vendor_profile_screen.dart';
import 'screens/riders/rider_management_screen.dart';
import 'screens/staff/staff_management_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'splash_screen.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await StorageService().init();
    runApp(const VendorApp());
  } catch (e, stackTrace) {
    debugPrint('Startup Error: $e');
    debugPrint('Stack Trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'App Failed to Start',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
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

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => VendorAuthProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => VendorOrderProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => RiderProvider()),
        ChangeNotifierProvider(create: (_) => PayoutProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProv, _) {
          return MaterialApp(
            title: 'Gas Lagba Vendor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const EmailEntryScreen(),
              '/otp-verify': (context) => const OtpVerifyScreen(),
              '/register': (context) => const VendorRegisterScreen(),
              '/pending-approval': (context) => const PendingApprovalScreen(),
              '/dashboard': (context) => const VendorMainNavigationShell(),
              '/orders': (context) => const VendorOrdersScreen(),
              '/inventory': (context) => const BranchInventoryScreen(),
              '/delivery-hours': (context) => const BranchDeliveryHoursScreen(),
              '/riders': (context) => const RiderManagementScreen(),
              '/payouts': (context) => const PayoutLedgerScreen(),
              '/subscription': (context) => const SubscriptionScreen(),
              '/staff': (context) => const StaffManagementScreen(),
              '/profile': (context) => const VendorProfileScreen(),
              '/notifications': (context) => const VendorNotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
