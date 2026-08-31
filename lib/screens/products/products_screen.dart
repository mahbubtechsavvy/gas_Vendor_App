import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedFilter = 'ALL'; // ALL, APPROVED, PENDING, REJECTED

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    await Future.wait([
      productProvider.fetchProducts(),
      productProvider.fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Cylinder Products & Catalogue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh Catalogue',
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Product> displayed = productProvider.products;
          if (_selectedFilter == 'APPROVED') {
            displayed = productProvider.approvedProducts;
          } else if (_selectedFilter == 'PENDING') {
            displayed = productProvider.pendingProducts;
          } else if (_selectedFilter == 'REJECTED') {
            displayed = productProvider.rejectedProducts;
          }

          return Column(
            children: [
              // Moderation notification banner
              if (productProvider.pendingProducts.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFF7ED),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top, color: Color(0xFFFF6600), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${productProvider.pendingProducts.length} product(s) pending Admin verification.',
                          style: const TextStyle(color: Color(0xFFC2410C), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Filter Chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All (${productProvider.products.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('APPROVED', 'Approved (${productProvider.approvedProducts.length})', color: Colors.green),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING', 'Pending (${productProvider.pendingProducts.length})', color: const Color(0xFFFF6600)),
                      if (productProvider.rejectedProducts.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildFilterChip('REJECTED', 'Rejected (${productProvider.rejectedProducts.length})', color: Colors.red),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Product list or empty
              Expanded(
                child: displayed.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayed.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = displayed[index];
                            return _buildProductCard(product);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: const Color(0xFFFF6600),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Cylinder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, {Color? color}) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: color ?? const Color(0xFF003496),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) {
        setState(() {
          _selectedFilter = key;
        });
      },
    );
  }

  Widget _buildProductCard(Product product) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (product.isApproved) {
      statusColor = Colors.green;
      statusText = 'Approved & Active';
      statusIcon = Icons.check_circle_outline;
    } else if (product.isPending) {
      statusColor = const Color(0xFFFF6600);
      statusText = 'Pending Admin Approval';
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = Colors.red;
      statusText = 'Rejected by Admin';
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.propane_tank, color: Color(0xFFFF6600), size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    if (product.nameBn != null && product.nameBn!.isNotEmpty)
                      Text(
                        product.nameBn!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    const SizedBox(height: 4),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.brand!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                      ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF6600)),
                  ),
                  if (product.deposit > 0)
                    Text(
                      '+৳${product.deposit.toStringAsFixed(0)} dep',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Status & Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (product.cylinderSizeKg != null)
                Text(
                  'Size: ${product.cylinderSizeKg} kg',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                ),
            ],
          ),

          // Rejection note if any
          if (product.isRejected && product.approvalNote != null && product.approvalNote!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Admin Note: ${product.approvalNote}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No products in this list',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap below to add your first cylinder product or pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _navigateToAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add Cylinder Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6600),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (result == true) {
      _loadProducts();
    }
  }
}
