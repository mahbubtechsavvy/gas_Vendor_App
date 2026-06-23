import 'vendor_status.dart';

class Vendor {
  final int? id;
  final String uniqueId; // Added uniqueId field
  final String name;
  final String? fatherName; // May not be in API response
  final String? village; // May not be in API response
  final String? houseName; // May not be in API response
  final String mobile;
  final String? nid;
  final String? email;
  final String? shopAddress;
  final String? businessName;
  final String? businessType; // gas, grocery, medical
  final bool isVerified;
  final bool isApproved;
  final String? profileImage;
  final String? bannerImage;
  final String subscriptionStatus; // active, inactive, expired
  final DateTime? subscriptionExpiry;
  final double? commissionRate;
  final VendorStatus status;
  final DateTime? createdAt;

  Vendor({
    this.id,
    required this.uniqueId,
    required this.name,
    this.fatherName,
    this.village,
    this.houseName,
    required this.mobile,
    this.nid,
    this.email,
    this.shopAddress,
    this.businessName,
    this.businessType,
    this.isVerified = false,
    this.isApproved = false,
    this.profileImage,
    this.bannerImage,
    this.subscriptionStatus = 'none',
    this.subscriptionExpiry,
    this.commissionRate,
    this.status = VendorStatus.pending,
    this.createdAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int?,
      uniqueId: json['unique_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fatherName:
          json['father_name'] as String? ?? '', // May not be returned by API
      village: json['village'] as String? ?? '', // May not be returned by API
      houseName:
          json['house_name'] as String? ?? '', // May not be returned by API
      mobile:
          json['phone'] as String? ??
          json['mobile'] as String? ??
          '', // API returns 'phone'
      nid:
          json['nid_number'] as String? ??
          json['nid'] as String?, // API returns 'nid_number'
      email: json['email'] as String?,
      shopAddress:
          json['shop_address'] as String? ??
          json['address'] as String?, // DB column is 'shop_address'
      businessName:
          json['shop_name'] as String? ??
          json['business_name'] as String?, // API returns 'shop_name'
      businessType: json['business_type'] as String?,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
      profileImage:
          json['profile_image'] as String? ??
          json['shop_image'] as String?, // DB column is 'profile_image'
      bannerImage: json['banner_image'] as String?,
      subscriptionStatus: json['subscription_status'] as String? ?? 'none',
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'])
          : null,
      commissionRate: json['commission_rate'] != null
          ? double.parse(json['commission_rate'].toString())
          : null,
      status: VendorStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unique_id': uniqueId,
      'name': name,
      'father_name': fatherName,
      'village': village,
      'house_name': houseName,
      'mobile': mobile,
      'nid': nid,
      'email': email,
      'shop_address': shopAddress,
      'business_name': businessName,
      'business_type': businessType,
      'is_verified': isVerified,
      'is_approved': isApproved,
      'profile_image': profileImage,
      'banner_image': bannerImage,
      'subscription_status': subscriptionStatus,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'commission_rate': commissionRate,
      'status': status.name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Vendor copyWith({
    int? id,
    String? uniqueId,
    String? name,
    String? fatherName,
    String? village,
    String? houseName,
    String? mobile,
    String? nid,
    String? email,
    String? shopAddress,
    String? businessName,
    String? businessType,
    bool? isVerified,
    bool? isApproved,
    String? profileImage,
    String? bannerImage,
    String? subscriptionStatus,
    DateTime? subscriptionExpiry,
    double? commissionRate,
    VendorStatus? status,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      village: village ?? this.village,
      houseName: houseName ?? this.houseName,
      mobile: mobile ?? this.mobile,
      nid: nid ?? this.nid,
      email: email ?? this.email,
      shopAddress: shopAddress ?? this.shopAddress,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      profileImage: profileImage ?? this.profileImage,
      bannerImage: bannerImage ?? this.bannerImage,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      commissionRate: commissionRate ?? this.commissionRate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
