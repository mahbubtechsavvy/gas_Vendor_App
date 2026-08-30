class RiderDeliveryItem {
  final String name;
  final int quantity;
  final double price;

  RiderDeliveryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory RiderDeliveryItem.fromJson(Map<String, dynamic> json) {
    return RiderDeliveryItem(
      name: json['name']?.toString() ?? 'LPG Cylinder',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    );
  }
}

class RiderDeliveryStore {
  final String name;
  final String? phone;
  final String address;
  final String? area;
  final String? district;

  RiderDeliveryStore({
    required this.name,
    this.phone,
    required this.address,
    this.area,
    this.district,
  });

  factory RiderDeliveryStore.fromJson(Map<String, dynamic> json) {
    return RiderDeliveryStore(
      name: json['name']?.toString() ?? 'Gas Lagba Store',
      phone: json['phone']?.toString(),
      address: json['address']?.toString() ?? '',
      area: json['area']?.toString(),
      district: json['district']?.toString(),
    );
  }
}

class RiderDeliveryCustomer {
  final String name;
  final String phone;
  final String address;
  final String? area;
  final String? district;

  RiderDeliveryCustomer({
    required this.name,
    required this.phone,
    required this.address,
    this.area,
    this.district,
  });

  factory RiderDeliveryCustomer.fromJson(Map<String, dynamic> json) {
    return RiderDeliveryCustomer(
      name: json['name']?.toString() ?? 'Customer',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      area: json['area']?.toString(),
      district: json['district']?.toString(),
    );
  }
}

class RiderDeliveryTask {
  final String deliveryId;
  final String orderId;
  final String? orderNumber;
  final String orderStatus;
  final String deliveryStatus;
  final String? deliveryType;
  final double payableAmount;
  final String paymentMethod;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final RiderDeliveryStore store;
  final RiderDeliveryCustomer customer;
  final List<RiderDeliveryItem> items;

  RiderDeliveryTask({
    required this.deliveryId,
    required this.orderId,
    this.orderNumber,
    required this.orderStatus,
    required this.deliveryStatus,
    this.deliveryType,
    required this.payableAmount,
    required this.paymentMethod,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.store,
    required this.customer,
    required this.items,
  });

  bool get isPickedUp => deliveryStatus == 'PICKED_UP' || pickedUpAt != null;
  bool get isDelivered => deliveryStatus == 'DELIVERED' || deliveredAt != null;
  bool get isAssigned => deliveryStatus == 'ASSIGNED';

  factory RiderDeliveryTask.fromJson(Map<String, dynamic> json) {
    return RiderDeliveryTask(
      deliveryId: json['deliveryId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString(),
      orderStatus: json['orderStatus']?.toString() ?? 'ACCEPTED',
      deliveryStatus: json['deliveryStatus']?.toString() ?? 'ASSIGNED',
      deliveryType: json['deliveryType']?.toString(),
      payableAmount: (json['payableAmount'] is num) ? (json['payableAmount'] as num).toDouble() : 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'].toString()) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.tryParse(json['pickedUpAt'].toString()) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt'].toString()) : null,
      store: RiderDeliveryStore.fromJson(json['store'] is Map<String, dynamic> ? json['store'] : {}),
      customer: RiderDeliveryCustomer.fromJson(json['customer'] is Map<String, dynamic> ? json['customer'] : {}),
      items: (json['items'] as List?)?.map((i) => RiderDeliveryItem.fromJson(i)).toList() ?? [],
    );
  }
}
