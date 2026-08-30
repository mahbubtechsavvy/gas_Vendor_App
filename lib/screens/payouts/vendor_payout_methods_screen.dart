import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payout_method_provider.dart';
import '../../models/payout_method_model.dart';
import 'add_payout_method_screen.dart';

class VendorPayoutMethodsScreen extends StatefulWidget {
  const VendorPayoutMethodsScreen({super.key});

  @override
  State<VendorPayoutMethodsScreen> createState() => _VendorPayoutMethodsScreenState();
}

class _VendorPayoutMethodsScreenState extends State<VendorPayoutMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PayoutMethodProvider>(context, listen: false).fetchPayoutMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Payment Receiving Accounts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PayoutMethodProvider>(context, listen: false).fetchPayoutMethods();
            },
          ),
        ],
      ),
      body: Consumer<PayoutMethodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.methods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFEFF6FF),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF003496), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Earnings from user orders are disbursed to your approved payment receiving accounts.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: provider.methods.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchPayoutMethods(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.methods.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = provider.methods[index];
                            return _buildMethodCard(item, provider);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddMethod,
        backgroundColor: const Color(0xFFFF6600),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMethodCard(VendorPayoutMethodModel item, PayoutMethodProvider provider) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (item.isApproved) {
      statusColor = Colors.green;
      statusText = 'Approved / Active';
      statusIcon = Icons.check_circle_outline;
    } else if (item.isPending) {
      statusColor = const Color(0xFFFF6600);
      statusText = 'Pending Approval';
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = Colors.red;
      statusText = 'Rejected';
      statusIcon = Icons.cancel_outlined;
    }

    Color brandColor;
    IconData brandIcon;
    switch (item.type) {
      case 'BKASH':
        brandColor = const Color(0xFFE2136E);
        brandIcon = Icons.account_balance_wallet;
        break;
      case 'NAGAD':
        brandColor = const Color(0xFFF7941D);
        brandIcon = Icons.account_balance_wallet;
        break;
      case 'ROCKET':
        brandColor = const Color(0xFF8C3494);
        brandIcon = Icons.account_balance_wallet;
        break;
      default:
        brandColor = const Color(0xFF003496);
        brandIcon = Icons.account_balance;
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(brandIcon, color: brandColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.type,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.accountType,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        if (item.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.accountNumber,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    if (item.accountName != null && item.accountName!.isNotEmpty)
                      Text(
                        'Name: ${item.accountName}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFF94A3B8), size: 20),
                onPressed: () => _confirmDelete(item, provider),
                tooltip: 'Delete Account',
              ),
            ],
          ),

          // Bank Details if Bank
          if (item.type == 'BANK' && item.bankName != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank: ${item.bankName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  if (item.branchName != null)
                    Text('Branch: ${item.branchName}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  if (item.routingNumber != null)
                    Text('Routing No: ${item.routingNumber}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Status & Note Row
          Row(
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
              const Spacer(),
              if (item.createdAt != null)
                Text(
                  'Added: ${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
            ],
          ),

          if (item.isRejected && item.adminNote != null && item.adminNote!.isNotEmpty)
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
                      'Admin Note: ${item.adminNote}',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          const Text(
            'No receiving accounts added yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your bKash, Nagad, Rocket or Bank account to receive payouts.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToAddMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Receiving Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6600),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPayoutMethodScreen()),
    );
    if (result == true) {
      Provider.of<PayoutMethodProvider>(context, listen: false).fetchPayoutMethods();
    }
  }

  void _confirmDelete(VendorPayoutMethodModel item, PayoutMethodProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to remove ${item.type} account (${item.accountNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deletePayoutMethod(item.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
