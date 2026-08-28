import '../core/money/money.dart';

enum SupplyType {
  standard,
  refill,
  newCylinder;

  static SupplyType fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'NEW_CYLINDER':
        return SupplyType.newCylinder;
      case 'REFILL':
        return SupplyType.refill;
      default:
        return SupplyType.standard;
    }
  }

  String get displayName {
    switch (this) {
      case SupplyType.newCylinder:
        return 'New Cylinder';
      case SupplyType.refill:
        return 'Refill';
      case SupplyType.standard:
        return 'Standard';
    }
  }
}

class InventoryItemModel {
  final String id;
  final String branchId;
  final String variantId;
  final String variantName;
  final String productId;
  final String productName;
  final SupplyType supplyType;
  final int currentStock;
  final int lowStockThreshold;
  final int pricePaisa;
  final int depositPaisa;

  InventoryItemModel({
    required this.id,
    required this.branchId,
    required this.variantId,
    required this.variantName,
    required this.productId,
    required this.productName,
    required this.supplyType,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.pricePaisa,
    required this.depositPaisa,
  });

  bool get isLowStock => currentStock <= lowStockThreshold;
  Money get price => Money.fromPaisa(pricePaisa);
  Money get deposit => Money.fromPaisa(depositPaisa);

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] is Map<String, dynamic> ? json['variant'] : {};
    final product = variant['product'] is Map<String, dynamic> ? variant['product'] : {};

    return InventoryItemModel(
      id: json['id'] ?? '',
      branchId: json['branchId'] ?? '',
      variantId: json['variantId'] ?? variant['id'] ?? '',
      variantName: variant['name'] ?? json['variantName'] ?? '',
      productId: product['id'] ?? json['productId'] ?? '',
      productName: product['name'] ?? json['productName'] ?? '',
      supplyType: SupplyType.fromString(variant['supplyType'] ?? json['supplyType']),
      currentStock: json['currentStock'] ?? json['stock'] ?? 0,
      lowStockThreshold: json['lowStockThreshold'] ?? 5,
      pricePaisa: variant['pricePaisa'] ?? json['pricePaisa'] ?? 0,
      depositPaisa: variant['depositPaisa'] ?? json['depositPaisa'] ?? 0,
    );
  }
}
