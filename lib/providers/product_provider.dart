import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/product.dart';

class ProductCategory {
  final String id;
  final String name;
  final String? nameBn;

  ProductCategory({required this.id, required this.name, this.nameBn});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    String en = 'LPG Cylinders';
    String? bn;
    if (json['nameI18n'] is Map) {
      en = json['nameI18n']['en'] ?? json['nameI18n']['bn'] ?? en;
      bn = json['nameI18n']['bn'];
    } else if (json['name'] != null) {
      en = json['name'].toString();
    }
    return ProductCategory(
      id: (json['id'] ?? json['publicId'] ?? '').toString(),
      name: en,
      nameBn: bn,
    );
  }
}

class ProductProvider with ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get approvedProducts => _products.where((p) => p.isApproved).toList();
  List<Product> get pendingProducts => _products.where((p) => p.isPending).toList();
  List<Product> get rejectedProducts => _products.where((p) => p.isRejected).toList();

  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock && !p.isOutOfStock).toList();
  List<Product> get outOfStockProducts => _products.where((p) => p.isOutOfStock).toList();

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.products);
      if (res is Map<String, dynamic> && res['items'] is List) {
        final List<dynamic> list = res['items'];
        _products = list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
      } else if (res is List) {
        _products = res.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        _products = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    try {
      final res = await _client.get(ApiEndpoints.categories);
      if (res is List) {
        _categories = res.map((c) => ProductCategory.fromJson(c as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _categories = (res['items'] as List).map((c) => ProductCategory.fromJson(c as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    if (_categories.isEmpty) {
      _categories = [
        ProductCategory(id: 'cat_lpg_cylinders', name: 'LPG Cylinders', nameBn: 'এলপিজি সিলিন্ডার'),
        ProductCategory(id: 'cat_regulators', name: 'Regulators & Safety', nameBn: 'রেগুলেটর ও নিরাপত্তা'),
        ProductCategory(id: 'cat_accessories', name: 'Pipes & Accessories', nameBn: 'পাইপ ও এক্সেসরিজ'),
        ProductCategory(id: 'cat_stoves', name: 'Gas Stoves & Burners', nameBn: 'গ্যাস চুলা'),
      ];
    }
    notifyListeners();
  }

  // Create Product via NestJS API
  Future<bool> createProduct({
    required String categoryId,
    required String nameEn,
    String? nameBn,
    String? descriptionEn,
    String? descriptionBn,
    String? brand,
    String? photoUrl,
    String unit = 'KG',
    double cylinderSizeKg = 12.0,
    String supplyType = 'REFILL',
    required double priceTaka,
    double? discountPriceTaka,
    double depositTaka = 0.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pricePaisa = (priceTaka * 100).round();
      final discountPricePaisa = discountPriceTaka != null ? (discountPriceTaka * 100).round() : null;
      final depositPaisa = (depositTaka * 100).round();

      final body = {
        'categoryId': categoryId,
        'nameI18n': {
          'en': nameEn.trim(),
          'bn': nameBn?.trim().isNotEmpty == true ? nameBn!.trim() : nameEn.trim(),
        },
        if (descriptionEn != null || descriptionBn != null)
          'descriptionI18n': {
            'en': descriptionEn?.trim() ?? nameEn.trim(),
            'bn': descriptionBn?.trim() ?? nameBn?.trim() ?? nameEn.trim(),
          },
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (photoUrl != null && photoUrl.trim().isNotEmpty) 'photoUrl': photoUrl.trim(),
        'unit': unit,
        'variants': [
          {
            'nameI18n': {
              'en': '$cylinderSizeKg kg $supplyType',
              'bn': '$cylinderSizeKg কেজি',
            },
            'cylinderSizeKg': cylinderSizeKg,
            'supplyType': supplyType,
            'pricePaisa': pricePaisa,
            if (discountPricePaisa != null) 'discountPricePaisa': discountPricePaisa,
            if (depositPaisa > 0) 'depositPaisa': depositPaisa,
            'sortOrder': 0,
          }
        ],
      };

      await _client.post(ApiEndpoints.products, body: body);
      await fetchProducts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update Product
  Future<bool> updateProductDetails(String productId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.patch(ApiEndpoints.product(productId), body: updates);
      await fetchProducts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Compatibility helper for legacy calls
  Future<bool> updateProduct(dynamic productId, Map<String, dynamic> updates) async {
    return updateProductDetails(productId.toString(), updates);
  }

  Future<bool> addProduct(Product product) async {
    return createProduct(
      categoryId: product.categoryId.toString(),
      nameEn: product.name,
      nameBn: product.nameBn,
      descriptionEn: product.description,
      brand: product.brand,
      unit: product.unit,
      cylinderSizeKg: product.cylinderSizeKg ?? 12.0,
      supplyType: product.supplyType,
      priceTaka: product.price,
      discountPriceTaka: product.discountPrice,
      depositTaka: product.deposit,
    );
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}
