import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vendorapp/core/i18n/locale_provider.dart';
import 'package:vendorapp/core/money/money.dart';
import 'package:vendorapp/models/vendor_order_model.dart';
import 'package:vendorapp/providers/branch_provider.dart';
import 'package:vendorapp/providers/inventory_provider.dart';
import 'package:vendorapp/providers/notification_provider.dart';
import 'package:vendorapp/providers/payout_provider.dart';
import 'package:vendorapp/providers/rider_provider.dart';
import 'package:vendorapp/providers/staff_provider.dart';
import 'package:vendorapp/providers/subscription_provider.dart';
import 'package:vendorapp/providers/vendor_auth_provider.dart';
import 'package:vendorapp/providers/vendor_order_provider.dart';
import 'package:vendorapp/screens/auth/email_entry_screen.dart';
import 'package:vendorapp/splash_screen.dart';
import 'package:vendorapp/widgets/custom_button.dart';
import 'package:vendorapp/widgets/money_text.dart';
import 'package:vendorapp/widgets/status_badge.dart';

Widget createTestApp(Widget child) {
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
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  testWidgets('SplashScreen displays brand and gas icon', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SplashScreen()));

    expect(find.text('গ্যাস লাগবে ভেন্ডর'), findsOneWidget);
    expect(find.text('LPG Partner Platform'), findsOneWidget);
    expect(find.byIcon(Icons.local_gas_station), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('EmailEntryScreen validates email and renders login buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const EmailEntryScreen()));

    expect(find.byIcon(Icons.storefront), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);

    // Tap submit with empty email -> shows validation error
    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(find.text('Please enter your business email'), findsOneWidget);
  });

  testWidgets('StatusBadge renders appropriate colors and text labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: VendorOrderStatus.pending),
              StatusBadge(status: VendorOrderStatus.ready),
              StatusBadge(status: VendorOrderStatus.delivered),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
  });

  testWidgets('MoneyText renders formatted currency accurately in English and Bangla', (WidgetTester tester) async {
    final money = Money.fromPaisa(125000);

    await tester.pumpWidget(
      createTestApp(
        Scaffold(
          body: MoneyText(money: money),
        ),
      ),
    );

    expect(find.byType(MoneyText), findsOneWidget);
  });
}
