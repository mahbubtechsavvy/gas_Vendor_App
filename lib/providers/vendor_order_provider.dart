import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/vendor_order_model.dart';

class VendorOrderProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<VendorOrderModel> _orders = [];
  VendorOrderModel? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<VendorOrderModel> get orders => _orders;
  VendorOrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered Queues
  List<VendorOrderModel> get pendingOrders =>
      _orders.where((o) => o.status == VendorOrderStatus.pending).toList();

  List<VendorOrderModel> get acceptedOrders =>
      _orders.where((o) => o.status == VendorOrderStatus.accepted).toList();

  List<VendorOrderModel> get preparingOrders =>
      _orders.where((o) => o.status == VendorOrderStatus.preparing).toList();

  List<VendorOrderModel> get readyOrders =>
      _orders.where((o) => o.status == VendorOrderStatus.ready).toList();

  List<VendorOrderModel> get outForDeliveryOrders =>
      _orders.where((o) => o.status == VendorOrderStatus.outForDelivery).toList();

  List<VendorOrderModel> get historyOrders =>
      _orders.where((o) => o.status.isTerminal).toList();

  List<VendorOrderModel> get cancellationRequests =>
      _orders.where((o) => o.hasCancellationRequest).toList();

  int get unacknowledgedPendingCount => pendingOrders.length;

  Future<void> fetchOrders({String? branchId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(
        ApiEndpoints.orders,
        branchId: branchId,
      );

      if (res is List) {
        _orders = res.map((e) => VendorOrderModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['orders'] is List) {
        _orders = (res['orders'] as List).map((e) => VendorOrderModel.fromJson(e)).toList();
      }

      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.order(orderId));
      _currentOrder = VendorOrderModel.fromJson(res);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    return _executeStateTransition(ApiEndpoints.acceptOrder(orderId), orderId);
  }

  Future<bool> startPreparing(String orderId) async {
    return _executeStateTransition(ApiEndpoints.preparingOrder(orderId), orderId);
  }

  Future<bool> markReady(String orderId) async {
    return _executeStateTransition(ApiEndpoints.readyOrder(orderId), orderId);
  }

  Future<bool> dispatchOrder(
    String orderId, {
    String? riderId,
    String deliveryType = 'STAFF_RIDER',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.assignDelivery,
        body: {
          'orderId': orderId,
          if (riderId != null && riderId.isNotEmpty) 'riderId': riderId,
          'deliveryType': deliveryType,
        },
      );
      await _client.post(
        ApiEndpoints.dispatchOrder(orderId),
        body: {
          if (riderId != null && riderId.isNotEmpty) 'riderId': riderId,
          'deliveryType': deliveryType,
        },
      ).catchError((_) => <String, dynamic>{});

      await fetchOrderDetails(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDelivered(String orderId, {bool codCollected = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.deliverOrder(orderId),
        body: {'codCashCollected': codCollected},
      );
      await fetchOrderDetails(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.rejectOrder(orderId),
        body: {'reason': reason},
      );
      await fetchOrderDetails(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> decideCancellationRequest(String orderId, bool approve) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.decideCancellation(orderId),
        body: {'decision': approve ? 'APPROVED' : 'REJECTED'},
      );
      await fetchOrderDetails(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> _executeStateTransition(String endpoint, String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(endpoint);
      await fetchOrderDetails(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
