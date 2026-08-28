import '../core/money/money.dart';
import 'operating_hours_model.dart';

class BranchModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String address;
  final String thana;
  final String district;
  final bool isOpen;
  final int deliveryFeePaisa;
  final List<String> coverageThanas;
  final OperatingHoursModel? operatingHours;

  BranchModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.address,
    required this.thana,
    required this.district,
    required this.isOpen,
    required this.deliveryFeePaisa,
    this.coverageThanas = const [],
    this.operatingHours,
  });

  Money get deliveryFee => Money.fromPaisa(deliveryFeePaisa);

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    OperatingHoursModel? hours;
    if (json['deliveryHours'] != null && json['deliveryHours'] is List) {
      hours = OperatingHoursModel.fromJson(json['deliveryHours']);
    } else if (json['operatingHours'] != null && json['operatingHours'] is List) {
      hours = OperatingHoursModel.fromJson(json['operatingHours']);
    }

    return BranchModel(
      id: json['id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      thana: json['thana'] ?? '',
      district: json['district'] ?? '',
      isOpen: json['isOpen'] ?? true,
      deliveryFeePaisa: json['deliveryFeePaisa'] ?? 5000,
      coverageThanas: (json['coverageThanas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      operatingHours: hours,
    );
  }

  BranchModel copyWith({
    bool? isOpen,
    int? deliveryFeePaisa,
    OperatingHoursModel? operatingHours,
  }) {
    return BranchModel(
      id: id,
      vendorId: vendorId,
      name: name,
      phone: phone,
      address: address,
      thana: thana,
      district: district,
      isOpen: isOpen ?? this.isOpen,
      deliveryFeePaisa: deliveryFeePaisa ?? this.deliveryFeePaisa,
      coverageThanas: coverageThanas,
      operatingHours: operatingHours ?? this.operatingHours,
    );
  }
}
