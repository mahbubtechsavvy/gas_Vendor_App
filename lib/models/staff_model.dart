enum StaffRole {
  owner,
  branchManager,
  branchStaff;

  static StaffRole fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'OWNER':
        return StaffRole.owner;
      case 'BRANCH_MANAGER':
        return StaffRole.branchManager;
      case 'BRANCH_STAFF':
      default:
        return StaffRole.branchStaff;
    }
  }

  String get displayName {
    switch (this) {
      case StaffRole.owner:
        return 'Business Owner';
      case StaffRole.branchManager:
        return 'Branch Manager';
      case StaffRole.branchStaff:
        return 'Branch Staff';
    }
  }

  bool get canManageStaff => this == StaffRole.owner;
  bool get canEditHours => this == StaffRole.owner || this == StaffRole.branchManager;
  bool get canRequestPayout => this == StaffRole.owner;
}

class StaffModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final StaffRole role;
  final List<String> assignedBranchIds;
  final bool isActive;

  StaffModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.assignedBranchIds = const [],
    this.isActive = true,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: StaffRole.fromString(json['role']),
      assignedBranchIds: (json['assignedBranchIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
    );
  }
}
