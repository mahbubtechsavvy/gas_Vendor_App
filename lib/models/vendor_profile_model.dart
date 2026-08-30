enum VendorStatus {
  pendingApproval,
  approved,
  rejected,
  suspended;

  static VendorStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'APPROVED':
        return VendorStatus.approved;
      case 'REJECTED':
        return VendorStatus.rejected;
      case 'SUSPENDED':
        return VendorStatus.suspended;
      default:
        return VendorStatus.pendingApproval;
    }
  }

  bool get isApproved => this == VendorStatus.approved;
  bool get isPending => this == VendorStatus.pendingApproval;
}

class VendorProfileModel {
  final String id;
  final String? uniqueCode;
  final String legalName;
  final String businessName;
  final String tradeLicenseNo;
  final String? nidNo;
  final String? nidPhotoKey;
  final String? nidPhotoUrl;
  final String? logoKey;
  final String? logoUrl;
  final String contactPhone;
  final String contactEmail;
  final VendorStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  VendorProfileModel({
    required this.id,
    this.uniqueCode,
    required this.legalName,
    required this.businessName,
    required this.tradeLicenseNo,
    this.nidNo,
    this.nidPhotoKey,
    this.nidPhotoUrl,
    this.logoKey,
    this.logoUrl,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    String legalName = json['legalName'] ?? '';
    String businessName = json['businessName'] ?? legalName;
    if (businessName.isEmpty && json['displayNameI18n'] is Map) {
      businessName = json['displayNameI18n']['en'] ?? json['displayNameI18n']['bn'] ?? '';
    }
    if (businessName.isEmpty) {
      businessName = json['name'] ?? '';
    }
    if (legalName.isEmpty) {
      legalName = businessName;
    }

    return VendorProfileModel(
      id: json['id'] ?? '',
      uniqueCode: json['uniqueCode']?.toString(),
      legalName: legalName,
      businessName: businessName,
      tradeLicenseNo: json['tradeLicenseNo'] ?? '',
      nidNo: json['nidNo']?.toString(),
      nidPhotoKey: json['nidPhotoKey']?.toString(),
      nidPhotoUrl: json['nidPhotoUrl']?.toString(),
      logoKey: json['logoKey']?.toString(),
      logoUrl: json['logoUrl']?.toString() ?? json['logoKey']?.toString(),
      contactPhone: json['contactPhone'] ?? json['phone'] ?? '',
      contactEmail: json['contactEmail'] ?? json['email'] ?? '',
      status: VendorStatus.fromString(json['status']),
      rejectionReason: json['rejectionReason'] ?? json['statusReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
