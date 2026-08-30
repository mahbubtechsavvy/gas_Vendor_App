import '../core/money/money.dart';

class SubscriptionPlanModel {
  final String id;
  final String code;
  final String name;
  final String nameBn;
  final int feeMonthlyPaisa;
  final int durationDays;
  final int branchLimit;
  final int staffLimit;
  final List<String> features;

  SubscriptionPlanModel({
    required this.id,
    required this.code,
    required this.name,
    this.nameBn = '',
    required this.feeMonthlyPaisa,
    this.durationDays = 30,
    this.branchLimit = 1,
    this.staffLimit = 3,
    this.features = const [],
  });

  Money get feeMonthly => Money.fromPaisa(feeMonthlyPaisa);

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    String nameEn = '';
    String nameBn = '';
    if (json['nameI18n'] is Map) {
      nameEn = json['nameI18n']['en'] ?? '';
      nameBn = json['nameI18n']['bn'] ?? '';
    } else if (json['name'] != null) {
      nameEn = json['name'].toString();
    }

    final pricePaisa = json['pricePaisa'] ?? json['feeMonthlyPaisa'] ?? 0;
    final entitlements = (json['entitlements'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['features'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      code: json['key'] ?? json['code'] ?? '',
      name: nameEn.isNotEmpty ? nameEn : (json['key'] ?? 'Plan'),
      nameBn: nameBn,
      feeMonthlyPaisa: pricePaisa is num ? pricePaisa.toInt() : 0,
      durationDays: json['durationDays'] is num ? (json['durationDays'] as num).toInt() : 30,
      branchLimit: json['branchLimit'] ?? 1,
      staffLimit: json['staffLimit'] ?? 3,
      features: entitlements,
    );
  }
}

class VendorSubscriptionModel {
  final String id;
  final String status; // ACTIVE, TRIAL, PENDING_PAYMENT, GRACE_PERIOD, PAST_DUE, EXPIRED, CANCELLED
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

  bool get isActive => status == 'ACTIVE' || status == 'TRIAL' || status == 'GRACE_PERIOD';
  bool get isPendingPayment => status == 'PENDING_PAYMENT';

  factory VendorSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final expiresStr = json['endsAt'] ?? json['currentPeriodEnd'] ?? json['expiresAt'];
    final expires = expiresStr != null
        ? DateTime.tryParse(expiresStr.toString()) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    final startsStr = json['startsAt'];
    final starts = startsStr != null
        ? DateTime.tryParse(startsStr.toString()) ?? DateTime.now()
        : DateTime.now();

    final diff = expires.difference(DateTime.now()).inDays;

    final plan = json['plan'] is Map<String, dynamic> ? json['plan'] as Map<String, dynamic> : null;
    String planName = 'Standard Partner';
    if (plan != null) {
      if (plan['nameI18n'] is Map) {
        planName = plan['nameI18n']['en'] ?? plan['nameI18n']['bn'] ?? planName;
      } else if (plan['name'] != null) {
        planName = plan['name'].toString();
      }
    } else if (json['planNameI18n'] is Map) {
      planName = json['planNameI18n']['en'] ?? json['planNameI18n']['bn'] ?? planName;
    } else if (json['planName'] != null) {
      planName = json['planName'].toString();
    }

    final planCode = json['planKey'] ?? json['planCode'] ?? (plan != null ? (plan['key'] ?? plan['code']) : null) ?? 'MONTHLY';

    return VendorSubscriptionModel(
      id: json['id']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'PENDING_PAYMENT').toUpperCase(),
      planCode: planCode.toString(),
      planName: planName,
      startsAt: starts,
      expiresAt: expires,
      daysRemaining: diff > 0 ? diff : 0,
      isInGracePeriod: json['status'] == 'GRACE_PERIOD',
    );
  }
}
