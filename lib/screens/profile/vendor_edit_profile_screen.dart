import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vendor_auth_provider.dart';

class VendorEditProfileScreen extends StatefulWidget {
  const VendorEditProfileScreen({super.key});

  @override
  State<VendorEditProfileScreen> createState() =>
      _VendorEditProfileScreenState();
}

class _VendorEditProfileScreenState extends State<VendorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;
  late TextEditingController _tradeLicenseController;
  late TextEditingController _nidController;

  File? _logoPhotoFile;
  String? _logoPhotoBase64;

  File? _nidPhotoFile;
  String? _nidPhotoBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<VendorAuthProvider>();
    final vendor = auth.vendorProfile;

    _businessNameController = TextEditingController(
      text: vendor?.businessName ?? vendor?.legalName ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: vendor?.contactPhone ?? '',
    );
    _contactEmailController = TextEditingController(
      text: vendor?.contactEmail ?? '',
    );
    _tradeLicenseController = TextEditingController(
      text: vendor?.tradeLicenseNo ?? '',
    );
    _nidController = TextEditingController(text: vendor?.nidNo ?? '');
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _tradeLicenseController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoPhoto() async {
    final loc = context.read<LocaleProvider>();
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                    : 'Take Store / Profile Photo',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'গ্যালারি থেকে পছন্দ করুন'
                    : 'Choose from Gallery',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _logoPhotoFile = file;
          _logoPhotoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    }
  }

  Future<void> _pickNidPhoto() async {
    final loc = context.read<LocaleProvider>();
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'এনআইডি কার্ডের ছবি তুলুন'
                    : 'Take Photo of NID Card',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'গ্যালারি থেকে এনআইডি ছবি বেছে নিন'
                    : 'Choose NID Photo from Gallery',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _nidPhotoFile = file;
          _nidPhotoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = context.read<LocaleProvider>();
    final auth = context.read<VendorAuthProvider>();

    setState(() => _isSaving = true);

    final success = await auth.updateVendorProfile(
      businessName: _businessNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      contactEmail: _contactEmailController.text.trim(),
      tradeLicenseNo: _tradeLicenseController.text.trim(),
      nidNo: _nidController.text.trim(),
      nidPhotoKey: _nidPhotoBase64,
      logoKey: _logoPhotoBase64,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isBangla
                ? 'প্রোফাইল সফলভাবে আপডেট হয়েছে'
                : 'Profile updated successfully!',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ??
                (loc.isBangla
                    ? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে'
                    : 'Failed to update profile'),
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final vendor = auth.vendorProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.isBangla ? 'প্রোফাইল সম্পাদনা' : 'Edit Vendor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unique Vendor ID Display Card
              if (vendor?.uniqueCode != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.isBangla
                                  ? 'আপনার অনন্য ভেন্ডর আইডি'
                                  : 'Your Unique Vendor ID',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '#${vendor!.uniqueCode}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Copy ID',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: vendor.uniqueCode!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.isBangla
                                    ? 'ভেন্ডর আইডি কপি হয়েছে!'
                                    : 'Vendor ID copied to clipboard!',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Store Logo / Profile Photo Upload Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _logoPhotoFile != null
                                    ? Image.file(
                                        _logoPhotoFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (vendor?.logoUrl != null &&
                                              vendor!.logoUrl!.isNotEmpty
                                          ? (vendor.logoUrl!.startsWith('data:')
                                                ? Image.memory(
                                                    base64Decode(
                                                      vendor.logoUrl!
                                                          .split(',')
                                                          .last,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.storefront,
                                                              size: 40,
                                                              color: AppTheme
                                                                  .primary,
                                                            ),
                                                  )
                                                : Image.network(
                                                    vendor.logoUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.storefront,
                                                              size: 40,
                                                              color: AppTheme
                                                                  .primary,
                                                            ),
                                                  ))
                                          : const Icon(
                                              Icons.storefront,
                                              size: 40,
                                              color: AppTheme.primary,
                                            )),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickLogoPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.isBangla
                            ? 'দোকানের লোগো / প্রোফাইল ছবি'
                            : 'Store Logo / Profile Photo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickLogoPhoto,
                        icon: const Icon(Icons.photo_camera, size: 16),
                        label: Text(
                          loc.isBangla ? 'ছবি পরিবর্তন করুন' : 'Change Photo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Business Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.isBangla
                                ? 'ব্যবসার তথ্য'
                                : 'Business Information',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla
                              ? 'প্রতিষ্ঠানের নাম'
                              : 'Business / Store Name',
                          prefixIcon: const Icon(Icons.storefront),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (loc.isBangla ? 'নাম আবশ্যক' : 'Name is required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: loc.isBangla
                              ? 'যোগাযোগের মোবাইল নম্বর'
                              : 'Contact Phone',
                          prefixIcon: const Icon(Icons.phone),
                          hintText: '01XXXXXXXXX',
                        ),
                        validator: (v) => (v == null || v.trim().length < 11)
                            ? (loc.isBangla
                                  ? 'সঠিক ফোন নম্বর দিন'
                                  : 'Enter a valid phone number')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: loc.isBangla
                              ? 'ইমেইল অ্যাড্রেস'
                              : 'Contact Email',
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? (loc.isBangla
                                  ? 'সঠিক ইমেইল দিন'
                                  : 'Enter a valid email')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tradeLicenseController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla
                              ? 'ট্রেড লাইসেন্স নম্বর'
                              : 'Trade License No.',
                          prefixIcon: const Icon(Icons.badge),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mandatory NID Identity Verification Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.isBangla
                                      ? 'জাতীয় পরিচয়পত্র (NID) যাচাইকরণ'
                                      : 'National ID (NID) Verification',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  loc.isBangla
                                      ? 'ভেন্ডর অ্যাকাউন্ট সক্রিয়করণের জন্য আবশ্যক'
                                      : 'Compulsory for active vendor status',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _nidController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.isBangla
                              ? 'এনআইডি নম্বর'
                              : 'National ID Number (10, 13, or 17 digits)',
                          prefixIcon: const Icon(Icons.credit_card),
                          hintText: 'e.g. 19922692837482910',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return loc.isBangla
                                ? 'এনআইডি নম্বর আবশ্যক'
                                : 'NID number is compulsory';
                          }
                          if (v.trim().length < 10) {
                            return loc.isBangla
                                ? 'কমপক্ষে ১০ ডিজিটের এনআইডি নম্বর দিন'
                                : 'NID must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.isBangla
                            ? 'এনআইডি কার্ডের ছবি আপলোড করুন'
                            : 'Upload NID Card Photo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickNidPhoto,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _nidPhotoFile != null
                                  ? AppTheme.success
                                  : AppTheme.border,
                              width: _nidPhotoFile != null ? 2 : 1,
                            ),
                          ),
                          child: _nidPhotoFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    _nidPhotoFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (vendor?.nidPhotoUrl != null &&
                                        vendor!.nidPhotoUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child:
                                            vendor.nidPhotoUrl!.startsWith(
                                              'data:',
                                            )
                                            ? Image.memory(
                                                base64Decode(
                                                  vendor.nidPhotoUrl!
                                                      .split(',')
                                                      .last,
                                                ),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildNidPlaceholder(loc),
                                              )
                                            : Image.network(
                                                vendor.nidPhotoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildNidPlaceholder(loc),
                                              ),
                                      )
                                    : _buildNidPlaceholder(loc)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        loc.isBangla ? 'পরিবর্তন সংরক্ষণ করুন' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNidPlaceholder(LocaleProvider loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 36, color: AppTheme.textSecondary),
        const SizedBox(height: 8),
        Text(
          loc.isBangla
              ? 'এনআইডি কার্ডের ছবি আপলোড করতে ট্যাপ করুন'
              : 'Tap to capture / upload NID Card Photo',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
