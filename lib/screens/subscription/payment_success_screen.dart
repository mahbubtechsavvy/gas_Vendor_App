import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../support/support_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop all subscription screens and go back to profile
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: Text('Subscription', style: ThemeConfig.heading3),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration Image
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Confetti decorations
                      Positioned(
                        top: 20,
                        left: 30,
                        child: Icon(
                          Icons.star,
                          color: Colors.red.withValues(alpha: 0.7),
                          size: 16,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 40,
                        child: Icon(
                          Icons.celebration,
                          color: Colors.green.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 40,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.blue.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ),
                      // Main trophy/celebration icon
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: ThemeConfig.orange,
                            size: 80,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.celebration,
                                color: ThemeConfig.primaryBlue,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.celebration,
                                color: ThemeConfig.orange,
                                size: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.space2XL),

              // Thank You Text
              Text(
                'Thank You',
                style: ThemeConfig.heading1.copyWith(
                  color: ThemeConfig.textPrimary,
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Message
              Text(
                'With In 6 Hours Our Teams\nWill Verify Your Payment After\nThat You Will Get A Mail/SMS\nFrom Our Gas Lagbe Teams Members',
                textAlign: TextAlign.center,
                style: ThemeConfig.bodyLarge.copyWith(
                  color: ThemeConfig.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: ThemeConfig.space2XL),

              // Support Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent, size: 24),
                label: const Text('SUPPORT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.darkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.space2XL,
                    vertical: ThemeConfig.spaceLG,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusFull),
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.space2XL),
            ],
          ),
        ),
      ),
    );
  }
}
