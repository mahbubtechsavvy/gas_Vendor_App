class RiderModel {
  final String id;
  final String fullName;
  final String phone;
  final String? photoKey;
  final String? photoUrl;
  final String? nidNo;
  final String? nidPhotoKey;
  final String? nidPhotoUrl;
  final String status;
  final String? rejectionReason;
  final String? branchId;
  final String? branchName;
  final bool isActive;
  final int activeDeliveriesCount;

  RiderModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.photoKey,
    this.photoUrl,
    this.nidNo,
    this.nidPhotoKey,
    this.nidPhotoUrl,
    this.status = 'ACTIVE',
    this.rejectionReason,
    this.branchId,
    this.branchName,
    this.isActive = true,
    this.activeDeliveriesCount = 0,
  });

  bool get isPending => status == 'PENDING_APPROVAL';
  bool get isApproved => status == 'ACTIVE';
  bool get isRejected => status == 'REJECTED';

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoKey: json['photoKey']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['photoKey']?.toString(),
      nidNo: json['nidNo']?.toString(),
      nidPhotoKey: json['nidPhotoKey']?.toString(),
      nidPhotoUrl: json['nidPhotoUrl']?.toString(),
      status: (json['status'] ?? (json['isActive'] == true ? 'ACTIVE' : 'INACTIVE')).toString().toUpperCase(),
      rejectionReason: json['rejectionReason']?.toString(),
      branchId: json['branchId']?.toString(),
      branchName: json['branchName']?.toString(),
      isActive: json['isActive'] ?? true,
      activeDeliveriesCount: json['activeDeliveriesCount'] ?? 0,
    );
  }
}
