import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// Verification badge widget - shows blue checkmark like Meta verified
class VerificationBadge extends StatelessWidget {
  final double size;
  final bool showBackground;

  const VerificationBadge({
    super.key,
    this.size = 20,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Icon(
        Icons.verified,
        color: const Color(0xFF1DA1F2), // Twitter/Meta blue
        size: size * 0.9,
      ),
    );
  }
}

/// Profile avatar with optional verification badge
class VerifiedProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isVerified;
  final VoidCallback? onTap;

  const VerifiedProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Profile image
          CircleAvatar(
            radius: radius,
            backgroundColor: ThemeConfig.primaryBlue.withValues(alpha: 0.1),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(
                    imageUrl!.startsWith('http')
                        ? imageUrl!
                        : (imageUrl!.startsWith('uploads/')
                              ? 'http://gasapp.atwebpages.com/$imageUrl'
                              : 'http://gasapp.atwebpages.com/uploads/vendors/$imageUrl'),
                    headers: const {'Referer': 'http://gasapp.atwebpages.com/'},
                  )
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: radius,
                    color: ThemeConfig.primaryBlue,
                  )
                : null,
          ),
          // Verification badge
          if (isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: VerificationBadge(size: radius * 0.5),
            ),
        ],
      ),
    );
  }
}

/// Small verification badge for inline text
class InlineVerificationBadge extends StatelessWidget {
  const InlineVerificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Icon(Icons.verified, color: Color(0xFF1DA1F2), size: 16),
    );
  }
}
