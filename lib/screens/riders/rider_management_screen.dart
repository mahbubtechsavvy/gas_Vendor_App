import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/rider_provider.dart';
import '../../widgets/empty_state_view.dart';

class RiderManagementScreen extends StatefulWidget {
  const RiderManagementScreen({super.key});

  @override
  State<RiderManagementScreen> createState() => _RiderManagementScreenState();
}

class _RiderManagementScreenState extends State<RiderManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderProvider>().fetchRiders();
    });
  }

  void _showAddRiderSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nidController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    File? photoFile;
    String? photoBase64;
    File? nidPhotoFile;
    String? nidPhotoBase64;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final loc = context.read<LocaleProvider>();

          Future<void> pickRiderPhoto() async {
            final picker = ImagePicker();
            final source = await showModalBottomSheet<ImageSource>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (sheetCtx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        loc.isBangla
                            ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                            : 'Take Rider Photo with Camera',
                      ),
                      onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        loc.isBangla
                            ? 'গ্যালারি থেকে ছবি পছন্দ করুন'
                            : 'Choose Rider Photo from Gallery',
                      ),
                      onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
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
                setModalState(() {
                  photoFile = file;
                  photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                });
              }
            }
          }

          Future<void> pickRiderNid() async {
            final picker = ImagePicker();
            final source = await showModalBottomSheet<ImageSource>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (sheetCtx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        loc.isBangla
                            ? 'ক্যামেরা দিয়ে NID ছবি তুলুন'
                            : 'Take NID Photo with Camera',
                      ),
                      onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        loc.isBangla
                            ? 'গ্যালারি থেকে NID ছবি নির্বাচন করুন'
                            : 'Choose NID from Gallery',
                      ),
                      onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
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
                setModalState(() {
                  nidPhotoFile = file;
                  nidPhotoBase64 =
                      'data:image/jpeg;base64,${base64Encode(bytes)}';
                });
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.isBangla
                              ? 'নতুন রাইডার যোগ করুন'
                              : 'Add New Delivery Rider',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.isBangla
                          ? 'অ্যাডমিন ভেরিফিকেশন ও অনুমোদনের জন্য রাইডারের ছবি, নাম, মোবাইল এবং এনআইডি কার্ড জমা দিন।'
                          : 'Rider requires admin identity approval before becoming active for deliveries.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rider Profile Photo Upload
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: photoFile != null
                                  ? Image.file(photoFile!, fit: BoxFit.cover)
                                  : const Icon(
                                      Icons.person,
                                      size: 44,
                                      color: AppTheme.primary,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: pickRiderPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: pickRiderPhoto,
                        child: Text(
                          loc.isBangla
                              ? 'রাইডারের ছবি আপলোড করুন'
                              : 'Upload Rider Profile Photo',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: loc.isBangla
                            ? 'রাইডারের পূর্ণ নাম *'
                            : 'Rider Full Name *',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (loc.isBangla
                                ? 'রাইডারের নাম আবশ্যক'
                                : 'Name is required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.isBangla
                            ? 'রাইডারের মোবাইল নম্বর *'
                            : 'Rider Mobile Number *',
                        prefixIcon: const Icon(Icons.phone_android),
                        hintText: '018XXXXXXXX',
                      ),
                      validator: (val) => val == null || val.trim().length < 11
                          ? (loc.isBangla
                                ? 'সঠিক মোবাইল নম্বর দিন'
                                : 'Valid 11-digit phone required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.isBangla
                            ? 'রাইডারের NID নম্বর *'
                            : 'Rider NID Card Number *',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        hintText: 'e.g. 19902690000000000',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (loc.isBangla
                                ? 'NID নম্বর আবশ্যক'
                                : 'NID number is required')
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // NID Card Photo Upload
                    Text(
                      loc.isBangla
                          ? 'রাইডারের NID কার্ডের ছবি *'
                          : 'Rider NID Document Photo *',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: pickRiderNid,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: nidPhotoFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  nidPhotoFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    size: 36,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    loc.isBangla
                                        ? 'NID কার্ডের ছবি আপলোড করুন'
                                        : 'Tap to upload NID document photo',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => isSubmitting = true);

                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(ctx);
                              final prov = context.read<RiderProvider>();

                              final ok = await prov.addRider(
                                fullName: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                photoKey: photoBase64,
                                nidNo: nidController.text.trim(),
                                nidPhotoKey: nidPhotoBase64,
                              );

                              setModalState(() => isSubmitting = false);
                              if (mounted) {
                                if (ok) {
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loc.isBangla
                                            ? 'রাইডার সফলভাবে যোগ হয়েছে! অ্যাডমিন অনুমোদনের অপেক্ষায় রয়েছে।'
                                            : 'Rider added! Awaiting admin verification & approval.',
                                      ),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        prov.error ?? 'Failed to add rider',
                                      ),
                                      backgroundColor: AppTheme.danger,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              loc.isBangla
                                  ? 'রাইডার জমা দিন'
                                  : 'Submit Rider for Approval',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final riderProv = context.watch<RiderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          loc.isBangla ? 'রাইডার ব্যবস্থাপনা' : 'Riders & Deliveries',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(loc.isBangla ? 'নতুন রাইডার' : 'Add Rider'),
        onPressed: _showAddRiderSheet,
      ),
      body: RefreshIndicator(
        onRefresh: () => riderProv.fetchRiders(),
        color: AppTheme.primary,
        child: riderProv.riders.isEmpty
            ? EmptyStateView(
                icon: Icons.delivery_dining,
                title: loc.isBangla ? 'কোনো রাইডার নেই' : 'No Delivery Riders',
                message: loc.isBangla
                    ? 'ডেলিভারির জন্য নতুন রাইডার যোগ করুন। রাইডার যোগ করার পর অ্যাডমিন কর্তৃক এনআইডি ভেরিফাই করা হবে।'
                    : 'Add riders to assign them to incoming customer orders. NID will be verified by admin.',
                actionText: loc.isBangla ? 'নতুন রাইডার যোগ করুন' : 'Add Rider',
                onAction: _showAddRiderSheet,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: riderProv.riders.length,
                itemBuilder: (context, index) {
                  final rider = riderProv.riders[index];

                  Color badgeBg;
                  Color badgeText;
                  String badgeLabel;

                  if (rider.status == 'PENDING_APPROVAL') {
                    badgeBg = AppTheme.warning.withValues(alpha: 0.12);
                    badgeText = AppTheme.warning;
                    badgeLabel = loc.isBangla
                        ? 'অনুমোদন অপেক্ষমাণ'
                        : 'Pending Approval';
                  } else if (rider.status == 'ACTIVE' ||
                      (rider.isActive && rider.status != 'REJECTED')) {
                    badgeBg = AppTheme.success.withValues(alpha: 0.12);
                    badgeText = AppTheme.success;
                    badgeLabel = loc.isBangla ? 'অনুমোদিত ও সক্রিয়' : 'Active';
                  } else {
                    badgeBg = AppTheme.danger.withValues(alpha: 0.12);
                    badgeText = AppTheme.danger;
                    badgeLabel = loc.isBangla ? 'বাতিল' : 'Rejected';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: badgeText.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      rider.photoUrl != null &&
                                          rider.photoUrl!.isNotEmpty
                                      ? (rider.photoUrl!.startsWith('data:')
                                            ? Image.memory(
                                                base64Decode(
                                                  rider.photoUrl!
                                                      .split(',')
                                                      .last,
                                                ),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.delivery_dining,
                                                      color: badgeText,
                                                      size: 24,
                                                    ),
                                              )
                                            : Image.network(
                                                rider.photoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.delivery_dining,
                                                      color: badgeText,
                                                      size: 24,
                                                    ),
                                              ))
                                      : Icon(
                                          Icons.delivery_dining,
                                          color: badgeText,
                                          size: 24,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rider.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rider.phone,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    color: badgeText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.isBangla
                                        ? 'এনআইডি স্ট্যাটাস'
                                        : 'NID Verification',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rider.nidNo != null &&
                                            rider.nidNo!.isNotEmpty
                                        ? 'NID: ${rider.nidNo}'
                                        : (loc.isBangla
                                              ? 'NID জমা দেওয়া হয়নি'
                                              : 'No NID submitted'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: rider.nidNo != null
                                          ? AppTheme.textPrimary
                                          : AppTheme.danger,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.call,
                                      color: AppTheme.primary,
                                    ),
                                    onPressed: () => launchUrl(
                                      Uri.parse('tel:${rider.phone}'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (rider.rejectionReason != null &&
                              rider.rejectionReason!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppTheme.danger,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${loc.isBangla ? 'বাতিলের কারণ' : 'Reason'}: ${rider.rejectionReason}',
                                      style: const TextStyle(
                                        color: AppTheme.danger,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
