import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'pending_approval_screen.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchAddressController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<VendorAuthProvider>();
    if (auth.pendingEmail != null) {
      _emailController.text = auth.pendingEmail!;
    }
    _districtController.text = 'Dhaka';
    _thanaController.text = 'Dhanmondi';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _tradeLicenseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _branchNameController.dispose();
    _branchAddressController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<VendorAuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in with your email OTP first to verify your identity.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    final success = await auth.registerVendor(
      businessName: _businessNameController.text.trim(),
      tradeLicenseNo: _tradeLicenseController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      contactEmail: _emailController.text.trim().toLowerCase(),
      initialBranchName: _branchNameController.text.trim(),
      branchAddress: _branchAddressController.text.trim(),
      thana: _thanaController.text.trim(),
      district: _districtController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        (route) => false,
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.isBangla ? 'ভেন্ডর পার্টনার নিবন্ধন' : 'Vendor Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'ব্যবসায়িক তথ্য' : 'Business Information',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'প্রতিষ্ঠানের নাম' : 'Business / Enterprise Name',
                          hintText: 'e.g. Dhaka Gas Agency',
                          prefixIcon: const Icon(Icons.business_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tradeLicenseController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'ট্রেড লাইসেন্স নম্বর' : 'Trade License Number',
                          hintText: 'e.g. TRAD/DNCC/123456/2026',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'অফিসিয়াল ইমেইল' : 'Official Business Email',
                          hintText: 'contact@enterprise.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'মালিক / ম্যানেজারের ফোন' : 'Contact Phone Number',
                          hintText: '+8801700000000',
                          prefixIcon: const Icon(Icons.phone_android),
                        ),
                        validator: (val) => val == null || val.trim().length < 11 ? 'Valid phone required' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Initial Branch Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'প্রথম ব্রাঞ্চের বিবরণ' : 'Primary Branch Details',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _branchNameController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'ব্রাঞ্চের নাম' : 'Branch Name',
                          hintText: 'e.g. Dhanmondi Outlet',
                          prefixIcon: const Icon(Icons.storefront_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _branchAddressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'পূর্ণ ঠিকানা' : 'Full Branch Address',
                          hintText: 'Road 8A, House 24, Dhanmondi',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _thanaController,
                              decoration: const InputDecoration(labelText: 'Thana'),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(labelText: 'District'),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: loc.isBangla ? 'আবেদন জমা দিন' : 'Submit Application',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
