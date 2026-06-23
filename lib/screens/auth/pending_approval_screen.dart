import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeConfig.warningColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: ThemeConfig.warningColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Application Pending',
              style: ThemeConfig.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your vendor application is currently under review. This process typically takes up to 72 hours.',
              style: ThemeConfig.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeConfig.borderColor),
              ),
              child: Column(
                children: [
                  _buildStep(
                    icon: Icons.check_circle,
                    color: ThemeConfig.successColor,
                    title: 'Registration Submitted',
                    isCompleted: true,
                  ),
                  _buildConnector(isCompleted: true),
                  _buildStep(
                    icon: Icons.admin_panel_settings,
                    color: ThemeConfig.warningColor,
                    title: 'Admin Review',
                    isCompleted: false,
                    isActive: true,
                  ),
                  _buildConnector(isCompleted: false),
                  _buildStep(
                    icon: Icons.store_mall_directory,
                    color: ThemeConfig.textLight,
                    title: 'Start Selling',
                    isCompleted: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color color,
    required String title,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? ThemeConfig.textPrimary
                : ThemeConfig.textSecondary,
          ),
        ),
        if (isActive) ...[
          const Spacer(),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      height: 24,
      width: 2,
      color: isCompleted ? ThemeConfig.successColor : ThemeConfig.borderColor,
    );
  }
}
