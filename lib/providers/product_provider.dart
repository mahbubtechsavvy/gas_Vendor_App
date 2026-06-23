import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Product> get lowStockProducts => 
      _products.where((p) => p.isLowStock && !p.isOutOfStock).toList();
  
  List<Product> get outOfStockProducts => 
      _products.where((p) => p.isOutOfStock).toList();

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiConfig.vendors}/products.php');

      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          final List<dynamic> data = response.data['products'] ?? [];
          _products = data.map((json) => Product.fromJson(json)).toList();
        } else {
          _error = response.data != null ? response.data['message'] : 'Failed to load products';
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add Product
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConfig.vendors}/products.php';
      
      final response = await _apiService.post(
        endpoint,
        data: product.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data['success'] == true) {
          await fetchProducts(); // Refresh products list
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = response.data != null ? response.data['message'] : 'Failed to add product';
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update Product
  Future<bool> updateProduct(int productId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConfig.vendors}/products.php?id=$productId';
      
      final response = await _apiService.put(
        endpoint,
        data: updates,
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          await fetchProducts(); // Refresh products list
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = response.data != null ? response.data['message'] : 'Failed to update product';
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete Product
  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        '${ApiConfig.vendors}/products.php?id=$productId',
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          await fetchProducts(); // Refresh products list
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = response.data != null ? response.data['message'] : 'Failed to delete product';
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Set Selected Product
  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
