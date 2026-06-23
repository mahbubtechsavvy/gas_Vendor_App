import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../widgets/ui_components.dart';

/// Demo screen showcasing all new UI components
/// This is for testing and reference purposes
class ComponentsDemo extends StatefulWidget {
  const ComponentsDemo({super.key});

  @override
  State<ComponentsDemo> createState() => _ComponentsDemoState();
}

class _ComponentsDemoState extends State<ComponentsDemo> {
  bool isShopOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: CustomAppBar(
        showPremiumBadge: true,
        onNotificationTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Notifications tapped')));
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Metric Cards
            Text('Metric Cards', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: ThemeConfig.spaceMD,
              crossAxisSpacing: ThemeConfig.spaceMD,
              childAspectRatio: 1.4,
              children: [
                MetricCard(
                  label: 'Total Orders',
                  value: '1,245',
                  color: ThemeConfig.purple,
                  onTap: () => _showMessage('Total Orders tapped'),
                ),
                MetricCard(
                  label: 'Revenue',
                  value: '৳ 85,320',
                  color: ThemeConfig.orange,
                  onTap: () => _showMessage('Revenue tapped'),
                ),
                MetricCard(
                  label: 'Pending Orders',
                  value: '18',
                  color: ThemeConfig.pink,
                  onTap: () => _showMessage('Pending Orders tapped'),
                ),
                MetricCard(
                  label: 'Avg Rating',
                  value: '4.8',
                  color: ThemeConfig.teal,
                  onTap: () => _showMessage('Avg Rating tapped'),
                ),
              ],
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Shop Toggle
            Text('Shop Toggle', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            ShopToggleCard(
              isOpen: isShopOpen,
              onChanged: (value) {
                setState(() {
                  isShopOpen = value;
                });
                _showMessage('Shop is now ${value ? "Open" : "Closed"}');
              },
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Quick Actions
            Text('Quick Actions', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionButton(
                  icon: Icons.add,
                  label: 'New Order',
                  onTap: () => _showMessage('New Order'),
                ),
                QuickActionButton(
                  icon: Icons.inventory_2_outlined,
                  label: 'Add Product',
                  onTap: () => _showMessage('Add Product'),
                ),
                QuickActionButton(
                  icon: Icons.archive_outlined,
                  label: 'Check Stock',
                  onTap: () => _showMessage('Check Stock'),
                ),
                QuickActionButton(
                  icon: Icons.headset_mic_outlined,
                  label: 'Support',
                  onTap: () => _showMessage('Support'),
                ),
              ],
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Subscription Banner
            Text('Subscription Banner', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            SubscriptionBanner(
              onTap: () => _showMessage('Subscription tapped'),
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Status Badges
            Text('Status Badges', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            Wrap(
              spacing: ThemeConfig.spaceSM,
              runSpacing: ThemeConfig.spaceSM,
              children: const [
                StatusBadge(status: 'Pending'),
                StatusBadge(status: 'Accepted'),
                StatusBadge(status: 'Processing'),
                StatusBadge(status: 'Delivered'),
                StatusBadge(status: 'Declined'),
              ],
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Order List Items
            Text('Order List Items', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            OrderListItem(
              customerName: 'Bab Koli',
              address: 'Miajan Haji Bari, Talua Chandpur',
              orderNumber: '#VGD001',
              date: '2024-07-28',
              items: 'Total Gas 12 kg x1',
              amount: '৳ 1,250',
              status: 'Pending',
              timeAgo: '08:43',
              onTap: () => _showMessage('Order tapped'),
            ),
            OrderListItem(
              customerName: 'Alice Wonderland',
              address: 'Bhuiyan house, Talua Chandpur',
              orderNumber: '#VGD002',
              date: '2024-07-27',
              items: 'Total Gas 12 kg x2 + 1 more items',
              amount: '৳ 4,600',
              status: 'Accepted',
              onTap: () => _showMessage('Order tapped'),
            ),
            OrderListItem(
              customerName: 'Charlie Chaplin',
              address: 'Khan house, Talua Chandpur',
              orderNumber: '#VGD004',
              date: '2024-07-25',
              items: 'Total Gas 12 kg x2',
              amount: '৳ 1,250',
              status: 'Delivered',
              onTap: () => _showMessage('Order tapped'),
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Product Cards
            Text('Product Cards', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            ProductCard(
              imageUrl: '',
              name: 'Total Gas 12 kg',
              description: '12 kg',
              price: '৳ 1,350',
              stockCount: 18,
              isInStock: true,
              onEdit: () => _showMessage('Edit product'),
              onDelete: () => _showMessage('Delete product'),
            ),
            ProductCard(
              imageUrl: '',
              name: 'Portable Camping Gas 2kg',
              description: '2 kg',
              price: '৳ 400',
              stockCount: 0,
              isInStock: false,
              onEdit: () => _showMessage('Edit product'),
              onDelete: () => _showMessage('Delete product'),
            ),
            ProductCard(
              imageUrl: '',
              name: 'Gas Hose 2m (High Pressure)',
              description: '2m',
              price: '৳ 350',
              isPendingApproval: true,
              onEdit: () => _showMessage('Edit product'),
              onDelete: () => _showMessage('Delete product'),
            ),

            const SizedBox(height: ThemeConfig.spaceXL),

            // Section: Social Icons
            Text('Social Icons', style: ThemeConfig.heading2),
            const SizedBox(height: ThemeConfig.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIconButton(
                  icon: Icons.facebook,
                  url: 'https://facebook.com',
                  onTap: () => _showMessage('Facebook'),
                ),
                const SizedBox(width: ThemeConfig.spaceMD),
                SocialIconButton(
                  icon: Icons.music_note,
                  url: 'https://tiktok.com',
                  onTap: () => _showMessage('TikTok'),
                ),
                const SizedBox(width: ThemeConfig.spaceMD),
                SocialIconButton(
                  icon: Icons.close,
                  url: 'https://x.com',
                  onTap: () => _showMessage('X (Twitter)'),
                ),
                const SizedBox(width: ThemeConfig.spaceMD),
                SocialIconButton(
                  icon: Icons.business,
                  url: 'https://linkedin.com',
                  onTap: () => _showMessage('LinkedIn'),
                ),
              ],
            ),

            const SizedBox(height: ThemeConfig.space2XL),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
