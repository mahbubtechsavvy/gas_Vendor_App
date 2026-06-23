import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../config/api_config.dart';
import '../../config/theme_config.dart';
import '../../services/shop_status_service.dart';
import '../../widgets/ui_components.dart';
import '../order/order_screen.dart';
import '../products/products_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTab;
  final bool profileOnlyMode;

  const DashboardScreen({
    super.key,
    this.initialTab = 0,
    this.profileOnlyMode = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  bool _isShopOpen = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _loadData();
  }

  Future<void> _loadData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    await Future.wait<void>([
      dashboardProvider.fetchDashboardStats(),
      dashboardProvider.fetchBanners(),
      orderProvider.fetchOrders(),
      productProvider.fetchProducts(),
    ]);
    await _loadShopStatus();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey) ?? '';
  }

  Future<void> _loadShopStatus() async {
    try {
      final token = await _getToken();
      if (token.isEmpty) return;
      final isOpen = await ShopStatusService.getShopStatus(token);
      if (mounted) {
        setState(() => _isShopOpen = isOpen);
      }
    } catch (e) {
      debugPrint('Failed to load shop status: $e');
    }
  }

  void _onTabTapped(int index) {
    // In profile-only mode, only allow Profile tab (index 3)
    if (widget.profileOnlyMode && index != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVerified =
        context.watch<AuthProvider>().vendor?.isVerified ?? false;
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: CustomAppBar(
        showPremiumBadge: isVerified,
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const OrderScreen(),
          const ProductsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ThemeConfig.primaryBlue,
        unselectedItemColor: ThemeConfig.textLight,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer3<AuthProvider, DashboardProvider, OrderProvider>(
      builder: (context, authProvider, dashboardProvider, orderProvider, child) {
        final stats = dashboardProvider.stats;

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConfig.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Overview Title
                Text('Dashboard Overview', style: ThemeConfig.heading2),
                const SizedBox(height: ThemeConfig.spaceLG),

                // Metric Cards Grid (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: ThemeConfig.spaceMD,
                  crossAxisSpacing: ThemeConfig.spaceMD,
                  childAspectRatio: 1.5,
                  children: [
                    MetricCard(
                      label: 'Total Orders',
                      value: '${stats?.totalOrders ?? 1245}',
                      color: ThemeConfig.purple,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                    MetricCard(
                      label: 'Revenue',
                      value: '৳ ${stats?.totalRevenue ?? 85320}',
                      color: ThemeConfig.orange,
                      onTap: () {
                        // Navigate to analytics
                      },
                    ),
                    MetricCard(
                      label: 'Pending Orders',
                      value: '${stats?.pendingOrders ?? 18}',
                      color: ThemeConfig.pink,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                    MetricCard(
                      label: 'Avg Rating',
                      value: '${stats?.averageRating ?? 4.8}',
                      color: ThemeConfig.teal,
                      onTap: () {
                        // Show ratings
                      },
                    ),
                  ],
                ),

                const SizedBox(height: ThemeConfig.spaceLG),

                // Shop Open/Close Toggle
                ShopToggleCard(
                  isOpen: _isShopOpen,
                  onChanged: (value) async {
                    setState(() {
                      _isShopOpen = value;
                    });

                    try {
                      final token = await _getToken();
                      final success = await ShopStatusService.updateShopStatus(
                        token,
                        value,
                      );
                      if (!success && mounted) {
                        setState(() => _isShopOpen = !value);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Shop is now ${value ? "Open" : "Closed"}'
                                  : 'Failed to update shop status',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isShopOpen = !value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update shop status: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: ThemeConfig.spaceXL),

                // Quick Actions
                Text('Quick Actions', style: ThemeConfig.heading3),
                const SizedBox(height: ThemeConfig.spaceMD),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickActionButton(
                      icon: Icons.add,
                      label: 'New Order',
                      onTap: () {
                        // Navigate to new order
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New Order')),
                        );
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Add Product',
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.archive_outlined,
                      label: 'Check Stock',
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.headset_mic_outlined,
                      label: 'Support',
                      onTap: () {
                        setState(() => _selectedIndex = 3);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: ThemeConfig.spaceXL),

                // Subscription Banner
                SubscriptionBanner(
                  onTap: () {
                    // Navigate to subscription screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigate to Subscription')),
                    );
                  },
                ),

                const SizedBox(height: ThemeConfig.spaceXL),

                // Recent Orders Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Orders', style: ThemeConfig.heading3),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                      child: Text(
                        'see all orders',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: ThemeConfig.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeConfig.spaceMD),

                // Recent Orders List
                orderProvider.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeConfig.spaceXL),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : orderProvider.orders.isEmpty
                    ? _buildEmptyState('No orders yet')
                    : Column(
                        children: orderProvider.orders
                            .take(5)
                            .map(
                              (order) => OrderListItem(
                                customerName: order.userName ?? 'Customer',
                                address:
                                    order.deliveryAddress ??
                                    'Address not available',
                                orderNumber: order.orderNumber,
                                date: order.createdAt != null
                                    ? order.createdAt!.toIso8601String().split(
                                        'T',
                                      )[0]
                                    : 'N/A',
                                items: _getOrderItemsSummary(order),
                                amount:
                                    '৳ ${order.finalAmount.toStringAsFixed(2)}',
                                status: _getOrderStatus(order.orderStatus),
                                timeAgo: _getTimeAgo(order.createdAt),
                                onTap: () {
                                  // Navigate to order details
                                  setState(() => _selectedIndex = 1);
                                },
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: ThemeConfig.space2XL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.space2XL),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: ThemeConfig.textLight),
          const SizedBox(height: ThemeConfig.spaceLG),
          Text(message, style: ThemeConfig.bodyMedium),
        ],
      ),
    );
  }

  String _getOrderItemsSummary(dynamic order) {
    // TODO: Parse actual order items
    return 'Total Gas 12 kg x1';
  }

  String _getOrderStatus(String? status) {
    if (status == null) return 'Pending';
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  String? _getTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return null;
    try {
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return null;
    }
  }
}
