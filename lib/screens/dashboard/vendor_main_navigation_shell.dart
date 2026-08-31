import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../providers/vendor_order_provider.dart';
import '../../widgets/floating_pill_nav_bar.dart';
import '../inventory/branch_inventory_screen.dart';
import '../order/vendor_orders_screen.dart';
import '../payouts/payout_ledger_screen.dart';
import '../profile/vendor_profile_screen.dart';
import 'branch_dashboard_screen.dart';

class VendorMainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const VendorMainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<VendorMainNavigationShell> createState() => _VendorMainNavigationShellState();
}

class _VendorMainNavigationShellState extends State<VendorMainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final orderProv = context.watch<VendorOrderProvider>();
    final pendingCount = orderProv.unacknowledgedPendingCount;

    final screens = const [
      BranchDashboardScreen(),
      VendorOrdersScreen(),
      BranchInventoryScreen(),
      PayoutLedgerScreen(),
      VendorProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: FloatingPillNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: [
          FloatingNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: loc.isBangla ? 'ড্যাশবোর্ড' : 'Dashboard',
          ),
          FloatingNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: loc.isBangla ? 'অর্ডার' : 'Orders',
            badgeCount: pendingCount,
          ),
          FloatingNavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: loc.isBangla ? 'স্টক' : 'Inventory',
          ),
          FloatingNavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: loc.isBangla ? 'আয়' : 'Payouts',
          ),
          FloatingNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: loc.isBangla ? 'প্রোফাইল' : 'Profile',
          ),
        ],
      ),
    );
  }
}
