import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/payout_provider.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/money_text.dart';

class PayoutLedgerScreen extends StatefulWidget {
  const PayoutLedgerScreen({super.key});

  @override
  State<PayoutLedgerScreen> createState() => _PayoutLedgerScreenState();
}

class _PayoutLedgerScreenState extends State<PayoutLedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayoutProvider>().fetchPayoutData();
    });
  }

  void _showRequestPayoutSheet() {
    final loc = context.read<LocaleProvider>();
    final payoutProv = context.read<PayoutProvider>();
    final amountController = TextEditingController();
    final accountController = TextEditingController();
    String method = 'bKash';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.tr('requestPayout'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'bKash', child: Text('bKash Merchant / Personal')),
                    DropdownMenuItem(value: 'Nagad', child: Text('Nagad')),
                    DropdownMenuItem(value: 'BANK', child: Text('Bank Transfer (BEFTN)')),
                  ],
                  onChanged: (val) => setModalState(() => method = val ?? 'bKash'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${loc.tr('payoutAmount')} (BDT)',
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  validator: (val) {
                    final numVal = int.tryParse(val ?? '');
                    if (numVal == null || numVal <= 0) return 'Enter a valid amount';
                    if (payoutProv.balance != null && (numVal * 100) > payoutProv.balance!.availableBalancePaisa) {
                      return 'Amount exceeds available balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: accountController,
                  decoration: const InputDecoration(
                    labelText: 'Account / Wallet Number',
                    hintText: 'e.g. 017XXXXXXXX or Bank details',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: loc.tr('confirm'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amountTaka = int.parse(amountController.text.trim());
                    Navigator.pop(ctx);
                    await payoutProv.requestPayout(
                      amountPaisa: amountTaka * 100,
                      paymentMethod: method,
                      accountDetails: accountController.text.trim(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final payoutProv = context.watch<PayoutProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final balance = payoutProv.balance;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('payouts')),
      ),
      body: RefreshIndicator(
        onRefresh: () => payoutProv.fetchPayoutData(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Overview Card
              Card(
                color: AppTheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('availableBalance'),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      if (balance != null)
                        MoneyText(
                          money: balance.availableBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text('৳0', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.tr('pendingBalance'), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              if (balance != null)
                                MoneyText(
                                  money: balance.pendingBalance,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              else
                                const Text('৳0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Disbursed', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              if (balance != null)
                                MoneyText(
                                  money: balance.totalDisbursed,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              else
                                const Text('৳0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (auth.role.canRequestPayout) ...[
                const SizedBox(height: 14),
                CustomButton(
                  text: loc.tr('requestPayout'),
                  icon: Icons.account_balance_wallet,
                  backgroundColor: AppTheme.accent,
                  onPressed: _showRequestPayoutSheet,
                ),
              ],

              const SizedBox(height: 24),

              Text(
                loc.isBangla ? 'লেনদেনের বিবরণী' : 'Ledger Statement',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              if (payoutProv.ledgerEntries.isEmpty)
                EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: loc.isBangla ? 'কোনো লেনদেন নেই' : 'No Transactions',
                  message: loc.isBangla
                      ? 'এখনও কোনো পেমেন্ট বা সেটেলমেন্ট রেকর্ড পাওয়া যায়নি।'
                      : 'No ledger transactions recorded yet.',
                )
              else
                ...payoutProv.ledgerEntries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: entry.type.isCredit ? AppTheme.successLight : AppTheme.dangerLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          entry.type.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: entry.type.isCredit ? AppTheme.success : AppTheme.danger,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        entry.description,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(entry.createdAt),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      trailing: MoneyText(
                        money: entry.amount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: entry.type.isCredit ? AppTheme.success : AppTheme.danger,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
