import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/vendor_order_model.dart';

class StatusBadge extends StatelessWidget {
  final VendorOrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case VendorOrderStatus.pending:
        bg = AppTheme.warningLight;
        fg = AppTheme.warning;
        label = 'Pending';
        break;
      case VendorOrderStatus.accepted:
        bg = AppTheme.primaryLight;
        fg = AppTheme.primary;
        label = 'Accepted';
        break;
      case VendorOrderStatus.preparing:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        label = 'Preparing';
        break;
      case VendorOrderStatus.ready:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF6D28D9);
        label = 'Ready';
        break;
      case VendorOrderStatus.outForDelivery:
        bg = AppTheme.accentLight;
        fg = AppTheme.accent;
        label = 'Out for Delivery';
        break;
      case VendorOrderStatus.delivered:
        bg = AppTheme.successLight;
        fg = AppTheme.success;
        label = 'Delivered';
        break;
      case VendorOrderStatus.cancelled:
        bg = AppTheme.dangerLight;
        fg = AppTheme.danger;
        label = 'Cancelled';
        break;
      case VendorOrderStatus.rejected:
        bg = AppTheme.dangerLight;
        fg = AppTheme.danger;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
