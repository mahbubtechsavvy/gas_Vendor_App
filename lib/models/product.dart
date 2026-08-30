class ProductVariant {
  final String id;
  final String? sku;
  final String name;
  final double? cylinderSizeKg;
  final String supplyType;
  final double price;
  final double? discountPrice;
  final double deposit;

  ProductVariant({
    required this.id,
    this.sku,
    required this.name,
    this.cylinderSizeKg,
    this.supplyType = 'REFILL',
    required this.price,
    this.discountPrice,
    this.deposit = 0.0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    String variantName = 'Standard Variant';
    if (json['nameI18n'] is Map) {
      variantName = json['nameI18n']['en'] ?? json['nameI18n']['bn'] ?? variantName;
    } else if (json['name'] != null) {
      variantName = json['name'].toString();
    }

    final pricePaisa = json['pricePaisa'] as num?;
    final priceVal = pricePaisa != null ? pricePaisa.toDouble() / 100.0 : (json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0);

    final discountPaisa = json['discountPricePaisa'] as num?;
    final discountVal = discountPaisa != null ? discountPaisa.toDouble() / 100.0 : (json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null);

    final depositPaisa = json['depositPaisa'] as num?;
    final depositVal = depositPaisa != null ? depositPaisa.toDouble() / 100.0 : (json['deposit'] != null ? double.tryParse(json['deposit'].toString()) ?? 0.0 : 0.0);

    return ProductVariant(
      id: (json['id'] ?? json['publicId'] ?? '').toString(),
      sku: json['sku'] as String?,
      name: variantName,
      cylinderSizeKg: json['cylinderSizeKg'] != null ? double.tryParse(json['cylinderSizeKg'].toString()) : null,
      supplyType: json['supplyType'] as String? ?? 'REFILL',
      price: priceVal,
      discountPrice: discountVal,
      deposit: depositVal,
    );
  }
}

class Product {
  final dynamic id; // String or int
  final String publicId;
  final dynamic vendorId;
  final dynamic categoryId;
  final String name;
  final String? nameBn;
  final String? description;
  final String? brand;
  final double price;
  final double? discountPrice;
  final double deposit;
  final double? cylinderSizeKg;
  final String supplyType;
  final String unit;
  final int stockQuantity;
  final int minStockAlert;
  final String? image;
  final List<String>? images;
  final String status; // ACTIVE, INACTIVE, DRAFT
  final String approvalStatus; // APPROVED, PENDING, REJECTED
  final String? approvalNote;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    String? publicId,
    required this.vendorId,
    required this.categoryId,
    required this.name,
    this.nameBn,
    this.description,
    this.brand,
    required this.price,
    this.discountPrice,
    this.deposit = 0.0,
    this.cylinderSizeKg,
    this.supplyType = 'REFILL',
    required this.unit,
    this.stockQuantity = 0,
    this.minStockAlert = 5,
    this.image,
    this.images,
    this.status = 'ACTIVE',
    this.approvalStatus = 'PENDING',
    this.approvalNote,
    this.variants = const [],
    this.createdAt,
    this.updatedAt,
  }) : publicId = publicId ?? id?.toString() ?? '';

  factory Product.fromJson(Map<String, dynamic> json) {
    String productName = '';
    String? prodBn;
    if (json['nameI18n'] is Map) {
      productName = json['nameI18n']['en'] ?? json['nameI18n']['bn'] ?? 'LPG Product';
      prodBn = json['nameI18n']['bn'];
    } else {
      productName = json['name'] as String? ?? 'LPG Product';
    }

    String? desc;
    if (json['descriptionI18n'] is Map) {
      desc = json['descriptionI18n']['en'] ?? json['descriptionI18n']['bn'];
    } else {
      desc = json['description'] as String?;
    }

    List<ProductVariant> parsedVariants = [];
    if (json['variants'] is List) {
      parsedVariants = (json['variants'] as List).map((v) => ProductVariant.fromJson(v as Map<String, dynamic>)).toList();
    }

    double prodPrice = 0.0;
    double? prodDiscountPrice;
    double prodDeposit = 0.0;
    double? prodSize;
    String prodSupply = 'REFILL';

    if (parsedVariants.isNotEmpty) {
      final firstVar = parsedVariants.first;
      prodPrice = firstVar.price;
      prodDiscountPrice = firstVar.discountPrice;
      prodDeposit = firstVar.deposit;
      prodSize = firstVar.cylinderSizeKg;
      prodSupply = firstVar.supplyType;
    } else if (json['price'] != null) {
      prodPrice = double.tryParse(json['price'].toString()) ?? 0.0;
      if (json['discount_price'] != null) {
        prodDiscountPrice = double.tryParse(json['discount_price'].toString());
      }
    }

    String? mainImage = json['image'] as String?;
    if (mainImage == null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final firstImg = (json['images'] as List).first;
      if (firstImg is Map) {
        mainImage = firstImg['url'] as String?;
      } else if (firstImg is String) {
        mainImage = firstImg;
      }
    }

    return Product(
      id: json['id'] ?? json['publicId'],
      publicId: (json['publicId'] ?? json['id'] ?? '').toString(),
      vendorId: json['vendor_id'] ?? json['vendorId'] ?? 0,
      categoryId: json['category_id'] ?? json['categoryId'] ?? 0,
      name: productName,
      nameBn: prodBn,
      description: desc,
      brand: json['brand'] as String?,
      price: prodPrice,
      discountPrice: prodDiscountPrice,
      deposit: prodDeposit,
      cylinderSizeKg: prodSize,
      supplyType: prodSupply,
      unit: json['unit'] as String? ?? 'KG',
      stockQuantity: (json['stock_quantity'] ?? json['stock'] ?? json['stockQuantity']) as int? ?? 0,
      minStockAlert: (json['min_stock_alert'] ?? json['minStockAlert']) as int? ?? 5,
      image: mainImage,
      status: (json['status'] as String? ?? 'ACTIVE').toUpperCase(),
      approvalStatus: (json['approvalStatus'] ?? json['approval_status'] ?? 'APPROVED').toString().toUpperCase(),
      approvalNote: json['approvalNote'] as String? ?? json['approval_note'] as String?,
      variants: parsedVariants,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
          : null,
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'vendor_id': vendorId,
      'category_id': categoryId,
      'name': name,
      'nameBn': nameBn,
      'description': description,
      'brand': brand,
      'price': price,
      'discount_price': discountPrice,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'min_stock_alert': minStockAlert,
      'image': image,
      'status': status,
      'approvalStatus': approvalStatus,
      'approvalNote': approvalNote,
    };
  }

  double get finalPrice => discountPrice ?? price;

  bool get isLowStock => stockQuantity <= minStockAlert;

  bool get isOutOfStock => stockQuantity == 0;

  bool get isApproved => approvalStatus == 'APPROVED';
  bool get isPending => approvalStatus == 'PENDING';
  bool get isRejected => approvalStatus == 'REJECTED';

  double get discountPercentage {
    if (discountPrice == null || discountPrice! >= price) return 0;
    return ((price - discountPrice!) / price * 100);
  }

  String? get imageUrl => image;
  int get stock => stockQuantity;
}
