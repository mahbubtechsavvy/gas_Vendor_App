enum VendorStatus {
  pending,
  approved,
  rejected,
  suspended;

  String get label {
    switch (this) {
      case VendorStatus.pending:
        return 'Pending Approval';
      case VendorStatus.approved:
        return 'Active';
      case VendorStatus.rejected:
        return 'Rejected';
      case VendorStatus.suspended:
        return 'Suspended';
    }
  }

  static VendorStatus fromString(String status) {
    return VendorStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => VendorStatus.pending,
    );
  }
}
