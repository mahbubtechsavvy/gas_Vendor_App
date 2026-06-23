import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../config/theme_config.dart';
import '../../widgets/ui_components.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Pending',
    'Accepted',
    'Processing',
    'Delivered',
    'Declined',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        toolbarHeight: 0, // Hide the toolbar, only show bottom tabs
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConfig.spaceLG,
              vertical: ThemeConfig.spaceSM,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: ThemeConfig.cardWhite,
                    selectedColor: ThemeConfig.primaryBlue,
                    labelStyle: ThemeConfig.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : ThemeConfig.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? ThemeConfig.primaryBlue
                          : ThemeConfig.borderColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredOrders = _getFilteredOrders(orderProvider.orders);

          if (filteredOrders.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(ThemeConfig.spaceLG),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildExpandableOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  List<dynamic> _getFilteredOrders(List<dynamic> orders) {
    if (_selectedFilter == 'All') {
      return orders;
    }
    return orders.where((order) {
      final status = order.orderStatus?.toLowerCase() ?? '';
      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  Widget _buildExpandableOrderCard(dynamic order) {
    final isPending = order.orderStatus?.toLowerCase() == 'pending';
    final status = _getOrderStatus(order.orderStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConfig.spaceMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        side: BorderSide(color: ThemeConfig.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(ThemeConfig.spaceLG),
          childrenPadding: const EdgeInsets.fromLTRB(
            ThemeConfig.spaceLG,
            0,
            ThemeConfig.spaceLG,
            ThemeConfig.spaceLG,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: ThemeConfig.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              (order.userName ?? 'C')[0].toUpperCase(),
              style: ThemeConfig.heading3.copyWith(
                color: ThemeConfig.primaryBlue,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.userName ?? 'Customer',
                      style: ThemeConfig.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPending && _getTimeAgo(order.createdAt) != null)
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
                            _getTimeAgo(order.createdAt)!,
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
              const SizedBox(height: 4),
              Text(
                order.deliveryAddress ?? 'Address not available',
                style: ThemeConfig.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderNumber ?? 'N/A'}',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: ThemeConfig.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.createdAt ?? '',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: ThemeConfig.textLight,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 8),
              Text(_getOrderItemsSummary(order), style: ThemeConfig.bodyMedium),
              const SizedBox(height: 4),
              Text(
                '৳ ${order.finalAmount ?? 0}',
                style: ThemeConfig.bodyLarge.copyWith(
                  color: ThemeConfig.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            if (isPending) ...[
              const Divider(),
              const SizedBox(height: ThemeConfig.spaceSM),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptOrder(order),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeConfig.spaceMD),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _declineOrder(order),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.statusDeclined,
                        side: BorderSide(color: ThemeConfig.statusDeclined),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: ThemeConfig.textLight,
          ),
          const SizedBox(height: ThemeConfig.spaceLG),
          Text(
            'No ${_selectedFilter == 'All' ? '' : _selectedFilter.toLowerCase()} orders',
            style: ThemeConfig.heading3.copyWith(
              color: ThemeConfig.textSecondary,
            ),
          ),
          const SizedBox(height: ThemeConfig.spaceSM),
          Text('Orders will appear here', style: ThemeConfig.bodyMedium),
        ],
      ),
    );
  }

  String _getOrderItemsSummary(dynamic order) {
    // TODO: Parse actual order items from order object
    return 'Item (1): Total Gas 12 kg x1';
  }

  String _getOrderStatus(String? status) {
    if (status == null) return 'Pending';
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  String? _getTimeAgo(String? createdAt) {
    if (createdAt == null) return null;
    try {
      final orderTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(orderTime);

      if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        final seconds = difference.inSeconds % 60;
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _acceptOrder(dynamic order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text('Accept order ${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.acceptOrder(order.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order accepted successfully')),
        );
      }
    }
  }

  Future<void> _declineOrder(dynamic order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Order'),
        content: Text(
          'Are you sure you want to decline order ${order.orderNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.statusDeclined,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.declineOrder(order.id, 'Vendor declined');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order declined')));
      }
    }
  }
}
