import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vendor_order_provider.dart';
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
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppTheme.primaryLight,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primary),
            label: loc.tr('dashboard'),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.receipt_long, color: AppTheme.primary),
            ),
            label: loc.tr('orders'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2, color: AppTheme.primary),
            label: loc.tr('inventory'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet, color: AppTheme.primary),
            label: loc.tr('payouts'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppTheme.primary),
            label: loc.tr('profile'),
          ),
        ],
      ),
    );
  }
}
