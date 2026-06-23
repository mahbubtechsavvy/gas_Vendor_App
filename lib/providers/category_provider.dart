import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiConfig.baseUrl}/categories.php');

      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          final List<dynamic> data = response.data['data'] ?? [];
          _categories = data.map((json) => Category.fromJson(json)).toList();
        } else {
          _error = response.data != null ? response.data['message'] : 'Failed to load categories';
        }
      } else {
        _error = 'Failed to fetch categories';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
