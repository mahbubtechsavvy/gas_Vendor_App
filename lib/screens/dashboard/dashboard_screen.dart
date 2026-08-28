import 'package:flutter/material.dart';
import 'vendor_main_navigation_shell.dart';

class DashboardScreen extends StatelessWidget {
  final int initialTab;
  final bool profileOnlyMode;

  const DashboardScreen({
    super.key,
    this.initialTab = 0,
    this.profileOnlyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return VendorMainNavigationShell(initialIndex: initialTab);
  }
}
