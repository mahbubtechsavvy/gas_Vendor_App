import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Dashboard Stats
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.dashboard);

      if (response.statusCode == 200) {
        _stats = DashboardStats.fromJson(response.data);
      }
    } catch (e) {
      _error = e.toString();
      // Set default stats on error for demo purposes
      _stats = DashboardStats();
    }

    _isLoading = false;
    _isLoading = false;
    notifyListeners();
  }

  List<String> _banners = [];
  List<String> get banners => _banners;

  // Fetch Banners
  Future<void> fetchBanners() async {
    try {
      if (ApiConfig.useDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Use demo data
        _banners = [
          'https://img.freepik.com/free-vector/flat-design-gas-station-banner-template_23-2149478768.jpg',
          'https://img.freepik.com/free-psd/gas-station-banner-template_23-2148645398.jpg',
          'https://img.freepik.com/free-vector/gas-delivery-service-banner_23-2148564287.jpg',
        ];
        notifyListeners();
        return;
      }

      debugPrint(
        '🎯 Fetching banners from: ${ApiConfig.baseUrl}/api/v1/user/banners.php',
      );

      final response = await _apiService.get('/api/v1/user/banners.php');

      debugPrint('📡 Banner response status: ${response.statusCode}');
      debugPrint('📡 Banner response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle response structure: {success: true, message: "...", data: [...]}
        List<dynamic> data = [];
        if (responseData['data'] != null) {
          data = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          data = responseData;
        }

        debugPrint('📸 Found ${data.length} banners in response');

        if (data.isEmpty) {
          debugPrint('⚠️ No banners found, using demo banners');
          _useDemoBanners();
          return;
        }

        _banners = data
            .map((item) {
              String imageUrl = item['image_url'] ?? item['image'] ?? '';
              debugPrint('🖼️ Original image URL: $imageUrl');

              // Construct full URL if it's a relative path
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                // Remove /api/v1 from base URL and add the image path
                final baseUrlWithoutApi = ApiConfig.baseUrl.replaceAll(
                  '/api/v1',
                  '',
                );
                imageUrl = '$baseUrlWithoutApi/$imageUrl';
                debugPrint('🔗 Constructed full URL: $imageUrl');
              }
              return imageUrl;
            })
            .where((url) => url.isNotEmpty)
            .toList();

        debugPrint('✅ Final banner URLs: $_banners');
        notifyListeners();
      } else {
        debugPrint('❌ Banner fetch failed with status: ${response.statusCode}');
        _useDemoBanners();
      }
    } catch (e) {
      // Fallback to demo banners if API fails
      debugPrint('❌ Error fetching banners: $e - Using demo banners');
      _useDemoBanners();
    }
  }

  void _useDemoBanners() {
    _banners = [
      'https://img.freepik.com/free-vector/flat-design-gas-station-banner-template_23-2149478768.jpg',
      'https://img.freepik.com/free-psd/gas-station-banner-template_23-2148645398.jpg',
      'https://img.freepik.com/free-vector/gas-delivery-service-banner_23-2148564287.jpg',
    ];
    notifyListeners();
  }

  // Fetch Sales Data
  Future<List<SalesData>> fetchSalesData(String period) async {
    try {
      final response = await _apiService.get('${ApiConfig.sales}/$period');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['sales'] ?? [];
        return data.map((json) => SalesData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
