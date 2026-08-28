import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/inventory_item_model.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<InventoryItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<InventoryItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalStock => _items.fold(0, (sum, i) => sum + i.currentStock);
  int get lowStockCount => _items.where((i) => i.isLowStock).length;

  Future<void> fetchInventory(String branchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(
        ApiEndpoints.branchInventory(branchId),
        branchId: branchId,
      );

      if (res is List) {
        _items = res.map((e) => InventoryItemModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['inventory'] is List) {
        _items = (res['inventory'] as List).map((e) => InventoryItemModel.fromJson(e)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> adjustStock({
    required String branchId,
    required String variantId,
    required int newQuantity,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.adjustInventory(branchId),
        branchId: branchId,
        body: {
          'variantId': variantId,
          'quantity': newQuantity,
          'reason': reason ?? 'Manual stock adjustment via Vendor App',
        },
      );

      await fetchInventory(branchId);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
