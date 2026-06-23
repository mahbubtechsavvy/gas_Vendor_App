class Order {
  final int? id;
  final String orderNumber;
  final int userId;
  final int vendorId;
  final int addressId;
  final double totalAmount;
  final double discountAmount;
  final double deliveryCharge;
  final double finalAmount;
  final String paymentMethod; // cod, bkash, online
  final String paymentStatus; // pending, paid, failed
  final String
  orderStatus; // pending, accepted, declined, preparing, ready, dispatched, delivered, cancelled
  final String? notes;
  final DateTime? scheduledTime;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final String? cancelledReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional related data
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? addressData;
  final List<OrderItem>? items;

  Order({
    this.id,
    required this.orderNumber,
    required this.userId,
    required this.vendorId,
    required this.addressId,
    required this.totalAmount,
    this.discountAmount = 0,
    this.deliveryCharge = 0,
    required this.finalAmount,
    this.paymentMethod = 'cod',
    this.paymentStatus = 'pending',
    this.orderStatus = 'pending',
    this.notes,
    this.scheduledTime,
    this.acceptedAt,
    this.deliveredAt,
    this.cancelledReason,
    this.createdAt,
    this.updatedAt,
    this.userData,
    this.addressData,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as int,
      vendorId: json['vendor_id'] as int,
      addressId: json['address_id'] as int,
      totalAmount: double.parse(json['total_amount'].toString()),
      discountAmount: double.parse(json['discount_amount']?.toString() ?? '0'),
      deliveryCharge: double.parse(json['delivery_charge']?.toString() ?? '0'),
      finalAmount: double.parse(json['final_amount'].toString()),
      paymentMethod: json['payment_method'] as String? ?? 'cod',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      orderStatus: json['order_status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      cancelledReason: json['cancelled_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userData: json['user'] as Map<String, dynamic>?,
      addressData: json['address'] as Map<String, dynamic>?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'vendor_id': vendorId,
      'address_id': addressId,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'delivery_charge': deliveryCharge,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'notes': notes,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_reason': cancelledReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isPending => orderStatus == 'pending';
  bool get isAccepted => orderStatus == 'accepted';
  bool get isDeclined => orderStatus == 'declined';
  bool get isDelivered => orderStatus == 'delivered';
  bool get isCancelled => orderStatus == 'cancelled';

  String get statusText {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'dispatched':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }

  // Helper getters for new dashboard
  String? get userName => userData?['name'] as String?;
  String? get deliveryAddress => addressData?['address'] as String?;
}

class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double discount;
  final double total;
  final Map<String, dynamic>? productData;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.discount = 0,
    required this.total,
    this.productData,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: double.parse(json['price'].toString()),
      discount: double.parse(json['discount']?.toString() ?? '0'),
      total: double.parse(json['total'].toString()),
      productData: json['product'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'total': total,
    };
  }
}
