import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme_config.dart';

/// Profile completion progress bar widget
class ProfileCompletionProgress extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileCompletionProgress({super.key, required this.profile});

  /// Calculate profile completion percentage
  int _calculateCompletion() {
    int completion = 0;

    // Required fields with weights
    final requiredFields = {
      'profile_image': 20,
      'name': 10,
      'phone': 10,
      'email': 10,
      'shop_name': 15,
      'shop_address': 15,
      'business_type': 10,
      'nid': 10,
    };

    for (var entry in requiredFields.entries) {
      final value = profile[entry.key];
      if (value != null && value.toString().isNotEmpty) {
        completion += entry.value;
      }
    }

    return completion;
  }

  String _getVendorId() {
    return profile['vendor_id'] ?? profile['unique_id'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calculateCompletion();
    final vendorId = _getVendorId();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor ID - Read only with copy
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.badge,
                  color: ThemeConfig.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor ID',
                      style: ThemeConfig.captionText.copyWith(
                        color: ThemeConfig.textLight,
                      ),
                    ),
                    Text(
                      vendorId.isNotEmpty ? vendorId : 'Not assigned',
                      style: ThemeConfig.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              if (vendorId.isNotEmpty)
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vendorId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vendor ID copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy Vendor ID',
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Profile Completion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: ThemeConfig.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completion%',
                style: ThemeConfig.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(completion),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completion),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Status message
          Text(
            _getStatusMessage(completion),
            style: ThemeConfig.captionText.copyWith(
              color: _getProgressColor(completion),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int completion) {
    if (completion >= 100) {
      return Colors.green;
    } else if (completion >= 70) {
      return Colors.orange;
    } else if (completion >= 40) {
      return ThemeConfig.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStatusMessage(int completion) {
    if (completion >= 100) {
      return '✓ Profile complete! You can now subscribe.';
    } else if (completion >= 70) {
      return 'Almost there! Complete remaining fields.';
    } else if (completion >= 40) {
      return 'Good progress! Keep filling your profile.';
    } else {
      return 'Please complete your profile to continue.';
    }
  }
}
