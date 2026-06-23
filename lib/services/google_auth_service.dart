import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/api_config.dart';

/// Google Authentication Service for Vendor App
/// Handles Google Sign-In and communicates with backend API
/// Uses google_sign_in v6.x API
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Sign in with Google for Vendors
  /// Returns vendor data and token if successful, null otherwise
  Future<Map<String, dynamic>?> signInWithGoogle({
    String? phone,
    String? shopName,
    String? address,
  }) async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      // Get user details from Google
      final String googleId = googleUser.id;
      final String email = googleUser.email;
      final String name = googleUser.displayName ?? '';
      final String? photoUrl = googleUser.photoUrl;

      debugPrint('Google Sign-In successful: $name ($email)');

      // Send to backend API
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google_signin.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'google_id': googleId,
          'email': email,
          'name': name,
          'profile_photo': photoUrl,
          'user_type': 'vendor', // This is for Vendor app
          'phone': phone ?? '',
          'shop_name': shopName ?? '$name\'s Shop',
          'address': address ?? '',
        }),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            return data;
          } else {
            debugPrint('API returned success: false - ${data['message']}');
            return null;
          }
        } catch (e) {
          debugPrint('JSON Decode Error: $e');
          debugPrint('Raw Body: ${response.body}');
          return null;
        }
      } else {
        debugPrint('API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('Google Sign-Out successful');
    } catch (e) {
      debugPrint('Google Sign-Out Error: $e');
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user (if signed in)
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }

  /// Disconnect Google account
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint('Google account disconnected');
    } catch (e) {
      debugPrint('Google disconnect Error: $e');
    }
  }
}
