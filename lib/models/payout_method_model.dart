class VendorPayoutMethodModel {
  final String id;
  final String vendorId;
  final String type; // BKASH, NAGAD, ROCKET, BANK
  final String accountType; // PERSONAL, AGENT, MERCHANT, SAVINGS, CURRENT
  final String accountNumber;
  final String? accountName;
  final String? bankName;
  final String? branchName;
  final String? routingNumber;
  final String status; // PENDING, APPROVED, REJECTED
  final String? adminNote;
  final bool isDefault;
  final DateTime? createdAt;

  VendorPayoutMethodModel({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.accountType,
    required this.accountNumber,
    this.accountName,
    this.bankName,
    this.branchName,
    this.routingNumber,
    required this.status,
    this.adminNote,
    this.isDefault = false,
    this.createdAt,
  });

  factory VendorPayoutMethodModel.fromJson(Map<String, dynamic> json) {
    return VendorPayoutMethodModel(
      id: (json['id'] ?? '').toString(),
      vendorId: (json['vendorId'] ?? '').toString(),
      type: (json['type'] ?? 'BKASH').toString().toUpperCase(),
      accountType: (json['accountType'] ?? 'PERSONAL').toString().toUpperCase(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      accountName: json['accountName'] as String?,
      bankName: json['bankName'] as String?,
      branchName: json['branchName'] as String?,
      routingNumber: json['routingNumber'] as String?,
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      adminNote: json['adminNote'] as String?,
      isDefault: json['isDefault'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';

  String get displayName {
    if (type == 'BANK') {
      return bankName != null ? '$bankName - $accountNumber' : 'Bank A/C - $accountNumber';
    }
    return '$type ($accountType) - $accountNumber';
  }
}
