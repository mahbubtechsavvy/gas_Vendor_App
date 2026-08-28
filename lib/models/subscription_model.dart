import '../core/money/money.dart';

class SubscriptionPlanModel {
  final String id;
  final String code;
  final String name;
  final int feeMonthlyPaisa;
  final int branchLimit;
  final int staffLimit;
  final List<String> features;

  SubscriptionPlanModel({
    required this.id,
    required this.code,
    required this.name,
    required this.feeMonthlyPaisa,
    required this.branchLimit,
    required this.staffLimit,
    this.features = const [],
  });

  Money get feeMonthly => Money.fromPaisa(feeMonthlyPaisa);

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      feeMonthlyPaisa: json['feeMonthlyPaisa'] ?? 0,
      branchLimit: json['branchLimit'] ?? 1,
      staffLimit: json['staffLimit'] ?? 3,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class VendorSubscriptionModel {
  final String id;
  final String status; // ACTIVE, PAST_DUE, GRACE_PERIOD, EXPIRED
  final String planCode;
  final String planName;
  final DateTime startsAt;
  final DateTime expiresAt;
  final int daysRemaining;
  final bool isInGracePeriod;

  VendorSubscriptionModel({
    required this.id,
    required this.status,
    required this.planCode,
    required this.planName,
    required this.startsAt,
    required this.expiresAt,
    required this.daysRemaining,
    required this.isInGracePeriod,
  });

  bool get isActive => status == 'ACTIVE' || status == 'GRACE_PERIOD';

  factory VendorSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] is Map<String, dynamic> ? json['plan'] : {};
    final expires = json['expiresAt'] != null
        ? DateTime.tryParse(json['expiresAt']) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    final diff = expires.difference(DateTime.now()).inDays;

    return VendorSubscriptionModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      planCode: json['planCode'] ?? plan['code'] ?? 'STANDARD',
      planName: json['planName'] ?? plan['name'] ?? 'Standard Partner',
      startsAt: json['startsAt'] != null
          ? DateTime.tryParse(json['startsAt']) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: expires,
      daysRemaining: diff > 0 ? diff : 0,
      isInGracePeriod: json['status'] == 'GRACE_PERIOD',
    );
  }
}
