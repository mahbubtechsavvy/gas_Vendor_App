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
  final String businessName;
  final String tradeLicenseNo;
  final String contactPhone;
  final String contactEmail;
  final VendorStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  VendorProfileModel({
    required this.id,
    required this.businessName,
    required this.tradeLicenseNo,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? json['name'] ?? '',
      tradeLicenseNo: json['tradeLicenseNo'] ?? '',
      contactPhone: json['contactPhone'] ?? json['phone'] ?? '',
      contactEmail: json['contactEmail'] ?? json['email'] ?? '',
      status: VendorStatus.fromString(json['status']),
      rejectionReason: json['rejectionReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
