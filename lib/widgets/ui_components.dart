import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/theme_config.dart';

// ==================== CUSTOM APP BAR ====================

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showPremiumBadge;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    this.showPremiumBadge = false,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeConfig.cardWhite,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          SvgPicture.asset('assets/images/Logo.svg', height: 40, width: 40),
          const SizedBox(width: 8),
          // Gas Lagbe Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Gas Lagbe',
                    style: ThemeConfig.heading3.copyWith(
                      color: ThemeConfig.primaryBlue,
                      fontSize: 20,
                    ),
                  ),
                  if (showPremiumBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Premium',
                        style: ThemeConfig.captionText.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VIP',
                        style: ThemeConfig.captionText.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onNotificationTap,
          color: ThemeConfig.textPrimary,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ThemeConfig.borderColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

// ==================== METRIC CARD ====================

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        decoration: ThemeConfig.metricCardDecoration(color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: ThemeConfig.metricLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: ThemeConfig.metricValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STATUS BADGE ====================

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final color = ThemeConfig.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusPill),
      ),
      child: Text(
        status,
        style: ThemeConfig.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

// ==================== SHOP TOGGLE CARD ====================

class ShopToggleCard extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onChanged;

  const ShopToggleCard({
    super.key,
    required this.isOpen,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.lime,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendor Shop',
                style: ThemeConfig.bodyMedium.copyWith(
                  color: ThemeConfig.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Open/Close',
                style: ThemeConfig.heading2.copyWith(
                  color: ThemeConfig.primaryBlue,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: isOpen,
              onChanged: onChanged,
              activeThumbColor: ThemeConfig.inStock,
              activeTrackColor: ThemeConfig.inStock.withValues(alpha: 0.5),
              inactiveThumbColor: ThemeConfig.outOfStock,
              inactiveTrackColor: ThemeConfig.outOfStock.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUICK ACTION BUTTON ====================

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeConfig.borderColor,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
            ),
            child: Icon(icon, size: 28, color: ThemeConfig.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: ThemeConfig.bodySmall.copyWith(
              color: ThemeConfig.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== SUBSCRIPTION BANNER ====================

class SubscriptionBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const SubscriptionBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spaceXL),
        decoration: BoxDecoration(
          gradient: ThemeConfig.darkBlueGradient,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          boxShadow: ThemeConfig.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fast Year',
                    style: ThemeConfig.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Subscription',
                    style: ThemeConfig.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'OFF',
                  style: ThemeConfig.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '40%',
                  style: ThemeConfig.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ORDER LIST ITEM ====================

class OrderListItem extends StatelessWidget {
  final String customerName;
  final String address;
  final String orderNumber;
  final String date;
  final String items;
  final String amount;
  final String status;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? timeAgo;

  const OrderListItem({
    super.key,
    required this.customerName,
    required this.address,
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.amount,
    required this.status,
    this.avatarUrl,
    this.onTap,
    this.onAccept,
    this.onDecline,
    this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeConfig.spaceMD),
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        decoration: BoxDecoration(
          color: ThemeConfig.cardWhite,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          border: Border.all(color: ThemeConfig.borderColor),
          boxShadow: ThemeConfig.cardShadow,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: ThemeConfig.primaryBlue.withValues(alpha: 0.1),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      customerName.isNotEmpty
                          ? customerName[0].toUpperCase()
                          : '?',
                      style: ThemeConfig.heading3.copyWith(
                        color: ThemeConfig.primaryBlue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: ThemeConfig.spaceMD),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          customerName,
                          style: ThemeConfig.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeAgo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConfig.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: ThemeConfig.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeAgo!,
                                style: ThemeConfig.captionText.copyWith(
                                  color: ThemeConfig.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items,
                    style: ThemeConfig.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        amount,
                        style: ThemeConfig.bodyLarge.copyWith(
                          color: ThemeConfig.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      StatusBadge(status: status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: ThemeConfig.textLight),
          ],
        ),
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final int? stockCount;
  final bool isInStock;
  final bool isPendingApproval;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    this.stockCount,
    this.isInStock = true,
    this.isPendingApproval = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeConfig.spaceMD),
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        decoration: BoxDecoration(
          color: ThemeConfig.cardWhite,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          border: Border.all(color: ThemeConfig.borderColor),
          boxShadow: ThemeConfig.cardShadow,
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: ThemeConfig.backgroundColor,
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? Icon(
                      Icons.propane_tank,
                      size: 40,
                      color: ThemeConfig.textLight,
                    )
                  : null,
            ),
            const SizedBox(width: ThemeConfig.spaceMD),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: ThemeConfig.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: ThemeConfig.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        price,
                        style: ThemeConfig.bodyLarge.copyWith(
                          color: ThemeConfig.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!isPendingApproval)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isInStock
                                    ? ThemeConfig.inStock
                                    : ThemeConfig.outOfStock,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isInStock
                                  ? '${stockCount ?? 0} in stock'
                                  : 'Out of Stock',
                              style: ThemeConfig.bodySmall.copyWith(
                                color: isInStock
                                    ? ThemeConfig.inStock
                                    : ThemeConfig.outOfStock,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      if (isPendingApproval)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConfig.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Approval Pending',
                            style: ThemeConfig.captionText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Icons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  color: ThemeConfig.textSecondary,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: ThemeConfig.statusDeclined,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SOCIAL ICON BUTTON ====================

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final VoidCallback? onTap;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.url,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ThemeConfig.darkBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
