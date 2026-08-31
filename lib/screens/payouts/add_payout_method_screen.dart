import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payout_method_provider.dart';

class AddPayoutMethodScreen extends StatefulWidget {
  const AddPayoutMethodScreen({super.key});

  @override
  State<AddPayoutMethodScreen> createState() => _AddPayoutMethodScreenState();
}

class _AddPayoutMethodScreenState extends State<AddPayoutMethodScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'BKASH'; // BKASH, NAGAD, ROCKET, BANK
  String _selectedAccountType = 'PERSONAL'; // PERSONAL, AGENT, MERCHANT, SAVINGS, CURRENT
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PayoutMethodProvider>(context, listen: false);
    final success = await provider.addPayoutMethod(
      type: _selectedType,
      accountType: _selectedAccountType,
      accountNumber: _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim().isNotEmpty ? _accountNameController.text.trim() : null,
      bankName: _selectedType == 'BANK' ? _bankNameController.text.trim() : null,
      branchName: _selectedType == 'BANK' ? _branchNameController.text.trim() : null,
      routingNumber: _selectedType == 'BANK' ? _routingNumberController.text.trim() : null,
      isDefault: _isDefault,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment receiving account submitted for Admin verification!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add payout account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PayoutMethodProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Payment Receiving Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.security, color: Color(0xFF003496), size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Verification Protocol',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Your payout accounts receive revenue from customer gas orders. New accounts require verification by Admin before withdrawals.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Channel Selector
                    const Text('Payment Channel *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeCard('BKASH', 'bKash', Icons.account_balance_wallet, const Color(0xFFE2136E)),
                        const SizedBox(width: 8),
                        _buildTypeCard('NAGAD', 'Nagad', Icons.account_balance_wallet, const Color(0xFFF7941D)),
                        const SizedBox(width: 8),
                        _buildTypeCard('ROCKET', 'Rocket', Icons.account_balance_wallet, const Color(0xFF8C3494)),
                        const SizedBox(width: 8),
                        _buildTypeCard('BANK', 'Bank', Icons.account_balance, const Color(0xFF003496)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Account Type
                    const Text('Account Type *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedAccountType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: _selectedType == 'BANK'
                          ? const [
                              DropdownMenuItem(value: 'CURRENT', child: Text('Current Account')),
                              DropdownMenuItem(value: 'SAVINGS', child: Text('Savings Account')),
                            ]
                          : const [
                              DropdownMenuItem(value: 'PERSONAL', child: Text('Personal Wallet')),
                              DropdownMenuItem(value: 'MERCHANT', child: Text('Merchant Account')),
                              DropdownMenuItem(value: 'AGENT', child: Text('Agent Wallet')),
                            ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedAccountType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Number
                    Text(
                      _selectedType == 'BANK' ? 'Bank Account Number *' : '$_selectedType Mobile Number *',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: _selectedType == 'BANK' ? TextInputType.text : TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: _selectedType == 'BANK' ? 'e.g. 1102938475' : 'e.g. 017XXXXXXXX',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Account Name
                    const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Mahbub Store / Mahbub Alam',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bank Details
                    if (_selectedType == 'BANK') ...[
                      const Text('Bank Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. City Bank / Dutch-Bangla Bank / Islami Bank',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Bank name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Branch Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _branchNameController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Gulshan Branch',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Routing Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _routingNumberController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 225271890',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Set as Default
                    SwitchListTile(
                      title: const Text('Set as Default Receiving Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatic payouts will disburse to this verified account.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      value: _isDefault,
                      activeColor: const Color(0xFFFF6600),
                      onChanged: (val) => setState(() => _isDefault = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6600),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Submit for Admin Approval',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedAccountType = type == 'BANK' ? 'CURRENT' : 'PERSONAL';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : const Color(0xFF64748B), size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
