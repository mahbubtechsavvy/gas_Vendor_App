import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  List<Order> _pendingOrders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Order> get pendingOrders => _pendingOrders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Orders
  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConfig.vendors}/orders',
        queryParameters: status != null ? {'status': status} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['orders'] ?? [];
        _orders = data.map((json) => Order.fromJson(json)).toList();

        // Filter pending orders
        _pendingOrders = _orders.where((order) => order.isPending).toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get Order Details
  Future<void> getOrderDetails(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiConfig.orders}/$orderId');

      if (response.statusCode == 200) {
        _selectedOrder = Order.fromJson(response.data['order']);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Accept Order
  Future<bool> acceptOrder(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (ApiConfig.useDemoMode) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      // Mock update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // In a real app, we'd verify the status change from backend
        // For demo, we just assume it worked.
        // We might need to manually update the order object here if we want immediate UI feedback
        // without re-fetching.
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final response = await _apiService.put(
        '${ApiConfig.vendors}/orders/$orderId/accept',
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Refresh orders list
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Decline Order
  Future<bool> declineOrder(int orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (ApiConfig.useDemoMode) {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final response = await _apiService.put(
        '${ApiConfig.vendors}/orders/$orderId/decline',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Refresh orders list
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update Order Status
  Future<bool> updateOrderStatus(int orderId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '${ApiConfig.orders}/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Refresh orders list
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
