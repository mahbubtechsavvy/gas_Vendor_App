import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ProfileService {
  static final ApiService _apiService = ApiService();

  /// Get vendor profile
  static Future<Map<String, dynamic>> getVendorProfile() async {
    try {
      final response = await _apiService.get('/vendor/get_profile.php');

      var data = response.data;
      if (data is String) {
        final start = data.indexOf('{');
        final end = data.lastIndexOf('}');
        if (start != -1 && end != -1 && end >= start) {
          try {
            data = jsonDecode(data.substring(start, end + 1));
          } catch (_) {}
        }
      }

      if (data is Map) {
        if (data['success'] == true) {
          return data['vendor'];
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch profile');
        }
      } else {
        final responseStr = response.data.toString().replaceAll('\n', ' ');
        final shortened = responseStr.length > 100
            ? responseStr.substring(0, 100)
            : responseStr;
        throw Exception('Unexpected response format: $shortened...');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Update vendor profile
  static Future<Map<String, dynamic>> updateVendorProfile({
    required String name,
    String? email,
    String? mobile,
    String? nid,
    String? fatherName,
    String? village,
    String? houseName,
    String? shopName,
    String? shopAddress,
    String? businessType,
    File? profileImage,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {'name': name};

      if (email != null && email.isNotEmpty) formDataMap['email'] = email;
      if (mobile != null && mobile.isNotEmpty) formDataMap['mobile'] = mobile;
      if (nid != null && nid.isNotEmpty) formDataMap['nid'] = nid;
      if (fatherName != null && fatherName.isNotEmpty) {
        formDataMap['father_name'] = fatherName;
      }
      if (village != null && village.isNotEmpty) {
        formDataMap['village'] = village;
      }
      if (houseName != null && houseName.isNotEmpty) {
        formDataMap['house_name'] = houseName;
      }
      if (shopName != null && shopName.isNotEmpty) {
        formDataMap['shop_name'] = shopName;
      }
      if (shopAddress != null && shopAddress.isNotEmpty) {
        formDataMap['shop_address'] = shopAddress;
      }
      if (businessType != null && businessType.isNotEmpty) {
        formDataMap['business_type'] = businessType;
      }

      // Add image if provided
      if (profileImage != null) {
        formDataMap['profile_image'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _apiService.post(
        ApiConfig.updateProfile,
        data: formData,
      );

      var data = response.data;
      if (data is String) {
        final start = data.indexOf('{');
        final end = data.lastIndexOf('}');
        if (start != -1 && end != -1 && end >= start) {
          try {
            data = jsonDecode(data.substring(start, end + 1));
          } catch (_) {}
        }
      }

      if (data is Map) {
        if (data['success'] == true) {
          return data['vendor'];
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } else {
        final responseStr = response.data.toString().replaceAll('\n', ' ');
        final shortened = responseStr.length > 100
            ? responseStr.substring(0, 100)
            : responseStr;
        throw Exception('Unexpected response format: $shortened...');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception('Server Error: ${e.response?.data}');
      }
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating: $e');
    }
  }
}
