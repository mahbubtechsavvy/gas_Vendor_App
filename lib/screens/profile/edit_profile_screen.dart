import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendorapp/services/profile_service.dart';
import 'package:vendorapp/config/theme_config.dart';
import 'package:vendorapp/widgets/profile_completion_progress.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _nidController;
  late TextEditingController _fatherNameController;
  late TextEditingController _villageController;
  late TextEditingController _houseController;
  late TextEditingController _shopNameController;
  late TextEditingController _shopAddressController;

  String? _selectedBusinessType;
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _businessTypes = [
    'Gas Cylinder',
    'Cooking Gas',
    'Industrial Gas',
    'Medical Gas',
    'LPG Distributor',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['name']);
    _emailController = TextEditingController(
      text: widget.profile['email'] ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.profile['mobile'] ?? widget.profile['phone'],
    );
    _nidController = TextEditingController(text: widget.profile['nid'] ?? '');
    _fatherNameController = TextEditingController(
      text: widget.profile['father_name'] ?? '',
    );
    _villageController = TextEditingController(
      text: widget.profile['village'] ?? '',
    );
    _houseController = TextEditingController(
      text: widget.profile['house_name'] ?? '',
    );
    _shopNameController = TextEditingController(
      text: widget.profile['shop_name'] ?? widget.profile['business_name'],
    );
    _shopAddressController = TextEditingController(
      text: widget.profile['shop_address'] ?? widget.profile['address'],
    );
    _selectedBusinessType = widget.profile['business_type'];
    if (_selectedBusinessType != null &&
        _selectedBusinessType!.isNotEmpty &&
        !_businessTypes.contains(_selectedBusinessType)) {
      _businessTypes.add(_selectedBusinessType!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nidController.dispose();
    _fatherNameController.dispose();
    _villageController.dispose();
    _houseController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ProfileService.updateVendorProfile(
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        nid: _nidController.text,
        fatherName: _fatherNameController.text,
        village: _villageController.text,
        houseName: _houseController.text,
        shopName: _shopNameController.text,
        shopAddress: _shopAddressController.text,
        businessType: _selectedBusinessType,
        profileImage: _selectedImage,
      );

      if (mounted) {
        // Calculate completion from current form values
        final fields = {
          'profile_image':
              _selectedImage != null ||
              (widget.profile['profile_image'] != null),
          'name': _nameController.text.isNotEmpty,
          'phone': _mobileController.text.isNotEmpty,
          'email': _emailController.text.isNotEmpty,
          'shop_name': _shopNameController.text.isNotEmpty,
          'shop_address': _shopAddressController.text.isNotEmpty,
          'business_type':
              _selectedBusinessType != null &&
              _selectedBusinessType!.isNotEmpty,
          'nid': _nidController.text.isNotEmpty,
        };
        final weights = {
          'profile_image': 20,
          'name': 10,
          'phone': 10,
          'email': 10,
          'shop_name': 15,
          'shop_address': 15,
          'business_type': 10,
          'nid': 10,
        };
        int completion = 0;
        for (var key in fields.keys) {
          if (fields[key] == true) completion += weights[key]!;
        }

        if (completion >= 100) {
          // Profile is complete — guide vendor to subscription
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile complete! Choose a subscription plan.'),
            ),
          );
          Navigator.pop(context, true); // pop edit screen
          Navigator.pushNamed(context, '/subscription');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.profile['profile_image'];

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Completion Progress with Vendor ID
              ProfileCompletionProgress(profile: widget.profile),
              const SizedBox(height: 8),

              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (imageUrl != null && imageUrl.isNotEmpty
                                      ? NetworkImage(
                                          imageUrl.startsWith('http')
                                              ? imageUrl
                                              : (imageUrl.contains(
                                                      'uploads/profiles/',
                                                    )
                                                    ? 'http://gasapp.atwebpages.com/$imageUrl'
                                                    : 'http://gasapp.atwebpages.com/uploads/vendors/$imageUrl'),
                                          headers: const {
                                            'Referer':
                                                'http://gasapp.atwebpages.com/',
                                          },
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            _selectedImage == null &&
                                (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: ThemeConfig.primaryColor,
                          radius: 20,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: "Father's Name",
                  prefixIcon: Icon(Icons.family_restroom),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nidController,
                decoration: const InputDecoration(
                  labelText: 'NID Number',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Contact Information
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Address Information
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(
                  labelText: 'Village',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _houseController,
                decoration: const InputDecoration(
                  labelText: 'House/Bari Name',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 24),

              // Business Information
              Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop/Business Name *',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                // Use initialValue instead of value to avoid deprecation warning
                initialValue: _selectedBusinessType,
                decoration: const InputDecoration(
                  labelText: 'Business Type',
                  prefixIcon: Icon(Icons.business),
                ),
                items: _businessTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedBusinessType = value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _shopAddressController,
                decoration: const InputDecoration(
                  labelText: 'Shop Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primaryColor,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
