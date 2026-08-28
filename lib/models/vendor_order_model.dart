import '../core/money/money.dart';

enum VendorOrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  rejected;

  static VendorOrderStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'ACCEPTED':
        return VendorOrderStatus.accepted;
      case 'PREPARING':
        return VendorOrderStatus.preparing;
      case 'READY':
        return VendorOrderStatus.ready;
      case 'OUT_FOR_DELIVERY':
        return VendorOrderStatus.outForDelivery;
      case 'DELIVERED':
        return VendorOrderStatus.delivered;
      case 'CANCELLED':
        return VendorOrderStatus.cancelled;
      case 'REJECTED':
        return VendorOrderStatus.rejected;
      default:
        return VendorOrderStatus.pending;
    }
  }

  bool get isActive =>
      this == VendorOrderStatus.pending ||
      this == VendorOrderStatus.accepted ||
      this == VendorOrderStatus.preparing ||
      this == VendorOrderStatus.ready ||
      this == VendorOrderStatus.outForDelivery;

  bool get isTerminal =>
      this == VendorOrderStatus.delivered ||
      this == VendorOrderStatus.cancelled ||
      this == VendorOrderStatus.rejected;

  String get displayName {
    switch (this) {
      case VendorOrderStatus.pending:
        return 'Pending';
      case VendorOrderStatus.accepted:
        return 'Accepted';
      case VendorOrderStatus.preparing:
        return 'Preparing';
      case VendorOrderStatus.ready:
        return 'Ready';
      case VendorOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case VendorOrderStatus.delivered:
        return 'Delivered';
      case VendorOrderStatus.cancelled:
        return 'Cancelled';
      case VendorOrderStatus.rejected:
        return 'Rejected';
    }
  }
}

class VendorOrderItemModel {
  final String id;
  final String productName;
  final String variantName;
  final int quantity;
  final int unitPricePaisa;
  final int depositPaisa;
  final int lineTotalPaisa;

  VendorOrderItemModel({
    required this.id,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPricePaisa,
    required this.depositPaisa,
    required this.lineTotalPaisa,
  });

  Money get unitPrice => Money.fromPaisa(unitPricePaisa);
  Money get deposit => Money.fromPaisa(depositPaisa);
  Money get lineTotal => Money.fromPaisa(lineTotalPaisa);

  factory VendorOrderItemModel.fromJson(Map<String, dynamic> json) {
    return VendorOrderItemModel(
      id: json['id'] ?? '',
      productName: json['productName'] ?? json['name'] ?? '',
      variantName: json['variantName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPricePaisa: json['unitPricePaisa'] ?? json['pricePaisa'] ?? 0,
      depositPaisa: json['depositPaisa'] ?? 0,
      lineTotalPaisa: json['lineTotalPaisa'] ?? 0,
    );
  }
}

class VendorOrderModel {
  final String id;
  final String orderNumber;
  final String branchId;
  final String branchName;
  final VendorOrderStatus status;
  final String customerName;
  final String customerPhone;
  final String deliveryAddressText;
  final String deliveryMode; // ASAP or SCHEDULED
  final String? deliverySlotFormatted;
  final String paymentMethod; // COD or ONLINE
  final int subtotalPaisa;
  final int depositTotalPaisa;
  final int deliveryFeePaisa;
  final int totalPaisa;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final bool hasCancellationRequest;
  final String? cancellationRequestReason;
  final List<VendorOrderItemModel> items;
  final DateTime createdAt;

  VendorOrderModel({
    required this.id,
    required this.orderNumber,
    required this.branchId,
    required this.branchName,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddressText,
    this.deliveryMode = 'ASAP',
    this.deliverySlotFormatted,
    this.paymentMethod = 'COD',
    required this.subtotalPaisa,
    this.depositTotalPaisa = 0,
    required this.deliveryFeePaisa,
    required this.totalPaisa,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.hasCancellationRequest = false,
    this.cancellationRequestReason,
    this.items = const [],
    required this.createdAt,
  });

  Money get subtotal => Money.fromPaisa(subtotalPaisa);
  Money get depositTotal => Money.fromPaisa(depositTotalPaisa);
  Money get deliveryFee => Money.fromPaisa(deliveryFeePaisa);
  Money get total => Money.fromPaisa(totalPaisa);

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map<String, dynamic> ? json['customer'] : {};
    final branch = json['branch'] is Map<String, dynamic> ? json['branch'] : {};
    final delivery = json['delivery'] is Map<String, dynamic> ? json['delivery'] : {};
    final rider = delivery['rider'] is Map<String, dynamic> ? delivery['rider'] : {};
    final slot = json['deliverySlot'] is Map<String, dynamic> ? json['deliverySlot'] : {};

    String? slotFormatted;
    if (slot['startTime'] != null && slot['endTime'] != null) {
      slotFormatted = '${slot['date'] ?? ''} (${slot['startTime']} - ${slot['endTime']})';
    }

    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => VendorOrderItemModel.fromJson(e))
            .toList() ??
        [];

    final cancelReq = json['cancellationRequest'] is Map<String, dynamic>
        ? json['cancellationRequest']
        : null;

    return VendorOrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      branchId: json['branchId'] ?? branch['id'] ?? '',
      branchName: branch['name'] ?? json['branchName'] ?? '',
      status: VendorOrderStatus.fromString(json['status']),
      customerName: customer['fullName'] ?? json['customerName'] ?? 'Customer',
      customerPhone: customer['phone'] ?? json['customerPhone'] ?? '',
      deliveryAddressText: json['deliveryAddressText'] ?? json['deliveryAddress'] ?? '',
      deliveryMode: json['deliveryMode'] ?? 'ASAP',
      deliverySlotFormatted: slotFormatted,
      paymentMethod: json['paymentMethod'] ?? 'COD',
      subtotalPaisa: json['subtotalPaisa'] ?? 0,
      depositTotalPaisa: json['depositTotalPaisa'] ?? 0,
      deliveryFeePaisa: json['deliveryFeePaisa'] ?? 0,
      totalPaisa: json['totalPaisa'] ?? json['grandTotalPaisa'] ?? 0,
      riderId: rider['id'] ?? json['riderId'],
      riderName: rider['fullName'] ?? json['riderName'],
      riderPhone: rider['phone'] ?? json['riderPhone'],
      hasCancellationRequest: cancelReq != null && cancelReq['status'] == 'PENDING',
      cancellationRequestReason: cancelReq?['reason'],
      items: itemsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
