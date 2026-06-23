import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../config/theme_config.dart';
import '../../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _idController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _ownerNameController.dispose();
    _contractNumberController.dispose();
    _idController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Support', style: ThemeConfig.heading3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.spaceLG),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Contact Form Card
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spaceXL),
                decoration: BoxDecoration(
                  color: ThemeConfig.purple,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
                  boxShadow: ThemeConfig.cardShadow,
                ),
                child: Column(
                  children: [
                    // Owner Name Field
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name:',
                      hint: 'Enter your name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: ThemeConfig.spaceLG),

                    // Contract Numbers Field
                    _buildTextField(
                      controller: _contractNumberController,
                      label: 'Owner Contract Numbers',
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: ThemeConfig.spaceLG),

                    // ID Field
                    _buildTextField(
                      controller: _idController,
                      label: 'ID:',
                      hint: 'Enter your vendor ID',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your vendor ID';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: ThemeConfig.spaceLG),

                    // Message Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Message',
                          style: ThemeConfig.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 6,
                          style: ThemeConfig.bodyMedium.copyWith(
                            color: ThemeConfig.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Describe your issue or question...',
                            hintStyle: ThemeConfig.bodyMedium.copyWith(
                              color: ThemeConfig.textLight,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConfig.radiusMedium,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(
                              ThemeConfig.spaceLG,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your message';
                            }
                            if (value.length < 10) {
                              return 'Message should be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ThemeConfig.spaceXL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitSupportTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeConfig.spaceLG,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeConfig.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: ThemeConfig.buttonText.copyWith(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.space2XL),

              // Emergency Contact Card
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spaceXL),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 64, 2, 105),
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
                  boxShadow: ThemeConfig.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Emergency Contract',
                      style: ThemeConfig.heading2.copyWith(
                        color: Colors.white,
                        
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spaceLG),
                    Text(
                      'Mahbubur Rahman',
                      style: ThemeConfig.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Founder and CEO\n Gas Lagbe',
                      style: ThemeConfig.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _makePhoneCall('+8801644274016'),
                      child: Text(
                        '+8801644274016',
                        style: ThemeConfig.heading3.copyWith(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ThemeConfig.space2XL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeConfig.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: ThemeConfig.bodyMedium.copyWith(
            color: ThemeConfig.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ThemeConfig.bodyMedium.copyWith(
              color: ThemeConfig.textLight,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ThemeConfig.spaceLG,
              vertical: ThemeConfig.spaceMD,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _submitSupportTicket() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? ticketNumber;
    String errorMessage = 'Failed to submit ticket';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey) ?? '';
      ticketNumber = await SupportService.createSupportTicket(
        token: token,
        ownerName: _ownerNameController.text.trim(),
        contractNumber: _contractNumberController.text.trim(),
        vendorId: _idController.text.trim(),
        message: _messageController.text.trim(),
      );
    } catch (e) {
      debugPrint('Support ticket error: $e');
      errorMessage = 'Network error. Please try again.';
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (ticketNumber != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: ThemeConfig.inStock,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Success'),
            ],
          ),
          content: Text(
            'Your support ticket #$ticketNumber has been submitted successfully. Our team will contact you soon.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      _ownerNameController.clear();
      _contractNumberController.clear();
      _idController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not call $phoneNumber')));
      }
    }
  }
}
