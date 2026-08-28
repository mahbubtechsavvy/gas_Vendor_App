class RiderModel {
  final String id;
  final String fullName;
  final String phone;
  final bool isActive;
  final int activeDeliveriesCount;

  RiderModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.isActive = true,
    this.activeDeliveriesCount = 0,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['isActive'] ?? true,
      activeDeliveriesCount: json['activeDeliveriesCount'] ?? 0,
    );
  }
}
