class Product {
  final int? id;
  final int vendorId;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String unit;
  final int stockQuantity;
  final int minStockAlert;
  final String? image;
  final List<String>? images;
  final String status; // active, inactive, out_of_stock
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.vendorId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.unit,
    this.stockQuantity = 0,
    this.minStockAlert = 5,
    this.image,
    this.images,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      vendorId: json['vendor_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      discountPrice: json['discount_price'] != null
          ? double.parse(json['discount_price'].toString())
          : null,
      unit: json['unit'] as String,
      stockQuantity: (json['stock_quantity'] ?? json['stock']) as int? ?? 0,
      minStockAlert: json['min_stock_alert'] as int? ?? 5,
      image: json['image'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'min_stock_alert': minStockAlert,
      'image': image,
      'images': images,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double get finalPrice => discountPrice ?? price;

  bool get isLowStock => stockQuantity <= minStockAlert;

  bool get isOutOfStock => stockQuantity == 0;

  double get discountPercentage {
    if (discountPrice == null || discountPrice! >= price) return 0;
    return ((price - discountPrice!) / price * 100);
  }

  // Helper getters for compatibility
  String? get imageUrl => image;
  int get stock => stockQuantity;

  Product copyWith({
    int? id,
    int? vendorId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? unit,
    int? stockQuantity,
    int? minStockAlert,
    String? image,
    List<String>? images,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      image: image ?? this.image,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
