/// Model for vendor's current subscription status
class VendorSubscription {
  final String vendorId;
  final String shopName;
  final String status; // active, expired, pending, none
  final bool hasSubscription;

  // Active/Expired subscription details
  final String? planName;
  final String? startDate;
  final String? endDate;
  final String? planExpired; // Human readable expiry: "March 2027"
  final int durationMonths;
  final String planSessionYear;
  final double monthsElapsed;
  final double price;

  VendorSubscription({
    required this.vendorId,
    required this.shopName,
    required this.status,
    this.hasSubscription = false,
    this.planName,
    this.startDate,
    this.endDate,
    this.planExpired,
    this.durationMonths = 0,
    this.planSessionYear = '',
    this.monthsElapsed = 0.0,
    this.price = 0,
  });

  factory VendorSubscription.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'] as Map<String, dynamic>?;

    return VendorSubscription(
      vendorId: json['vendor_id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? '',
      status: json['status'] as String? ?? 'none',
      hasSubscription: json['has_subscription'] == true,
      planName: sub?['plan_name'] as String?,
      startDate: sub?['start_date'] as String?,
      endDate: sub?['end_date'] as String?,
      planExpired: sub?['plan_expired'] as String?,
      durationMonths: sub?['duration_months'] as int? ?? 0,
      planSessionYear: sub?['plan_session_year'] as String? ?? '',
      monthsElapsed: (sub?['months_elapsed'] as num?)?.toDouble() ?? 0.0,
      price: (sub?['price'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isPending => status == 'pending';
  bool get isNone => status == 'none';
}
