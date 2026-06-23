import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Google Sign-In Button Widget for Vendor App
/// Can be used in Login or Registration screens
class GoogleSignInButton extends StatefulWidget {
  final Function(Map<String, dynamic> vendorData) onSuccess;
  final Function(String error) onError;
  final String? phone;
  final String? shopName;
  final String? address;

  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
    required this.onError,
    this.phone,
    this.shopName,
    this.address,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleAuthService _googleAuth = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _googleAuth.signInWithGoogle(
        phone: widget.phone,
        shopName: widget.shopName,
        address: widget.address,
      );

      if (result != null && result['success'] == true) {
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
        await prefs.setString('vendor_data', result['user'].toString());
        await prefs.setBool('is_logged_in', true);

        // Call success callback
        widget.onSuccess(result);
      } else {
        widget.onError('Google Sign-In failed. Please try again.');
      }
    } catch (e) {
      widget.onError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.login, size: 24);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
