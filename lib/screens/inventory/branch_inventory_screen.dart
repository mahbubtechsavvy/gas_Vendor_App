import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/inventory_item_model.dart';
import '../../providers/branch_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/money_text.dart';

class BranchInventoryScreen extends StatefulWidget {
  const BranchInventoryScreen({super.key});

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final branchId = context.read<BranchProvider>().currentBranchId;
      if (branchId != null) {
        context.read<InventoryProvider>().fetchInventory(branchId);
      }
    });
  }

  void _showAdjustStockSheet(InventoryItemModel item) {
    final loc = context.read<LocaleProvider>();
    final branchId = context.read<BranchProvider>().currentBranchId;
    if (branchId == null) return;

    final qtyController = TextEditingController(text: '${item.currentStock}');
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.tr('adjustStock'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.productName} (${item.variantName})',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.tr('stockCount'),
                prefixIcon: const Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment (Optional)',
                hintText: 'e.g. Received new shipment',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: loc.tr('save'),
              onPressed: () async {
                final qty = int.tryParse(qtyController.text.trim());
                if (qty != null && qty >= 0) {
                  Navigator.pop(ctx);
                  final invProv = context.read<InventoryProvider>();
                  await invProv.adjustStock(
                    branchId: branchId,
                    variantId: item.variantId,
                    newQuantity: qty,
                    reason: reasonController.text.trim(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final branchProv = context.watch<BranchProvider>();
    final invProv = context.watch<InventoryProvider>();
    final branchId = branchProv.currentBranchId;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('inventory')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (branchId != null) {
            await invProv.fetchInventory(branchId);
          }
        },
        color: AppTheme.primary,
        child: invProv.items.isEmpty
            ? EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: loc.isBangla ? 'কোনো পণ্য পাওয়া যায়নি' : 'No Inventory Items',
                message: loc.isBangla
                    ? 'আপনার ব্রাঞ্চে কোনো সিলিন্ডার যুক্ত করা হয়নি।'
                    : 'No gas cylinder products found in this branch catalog.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invProv.items.length,
                itemBuilder: (context, index) {
                  final item = invProv.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.supplyType.displayName,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.variantName,
                                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item.isLowStock ? AppTheme.dangerLight : AppTheme.successLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.currentStock} Units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: item.isLowStock ? AppTheme.danger : AppTheme.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('${loc.isBangla ? 'মূল্য: ' : 'Price: '} ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  MoneyText(money: item.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  if (item.depositPaisa > 0) ...[
                                    Text(' (+ Dep. ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                    MoneyText(money: item.deposit, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 12)),
                                    const Text(')', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                  ],
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                icon: const Icon(Icons.edit, size: 14),
                                label: Text(loc.isBangla ? 'স্টক পরিবর্তন' : 'Adjust', style: const TextStyle(fontSize: 12)),
                                onPressed: () => _showAdjustStockSheet(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
