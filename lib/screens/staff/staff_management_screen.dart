import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/staff_model.dart';
import '../../providers/branch_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaff();
    });
  }

  void _showInviteStaffSheet() {
    final loc = context.read<LocaleProvider>();
    final branchProv = context.read<BranchProvider>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    StaffRole role = StaffRole.branchStaff;
    final selectedBranchIds = <String>[];
    if (branchProv.currentBranchId != null) {
      selectedBranchIds.add(branchProv.currentBranchId!);
    }
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.tr('inviteStaff'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Staff Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<StaffRole>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Staff Role'),
                  items: const [
                    DropdownMenuItem(value: StaffRole.branchStaff, child: Text('Branch Staff')),
                    DropdownMenuItem(value: StaffRole.branchManager, child: Text('Branch Manager')),
                    DropdownMenuItem(value: StaffRole.owner, child: Text('Co-Owner')),
                  ],
                  onChanged: (val) => setModalState(() => role = val ?? StaffRole.branchStaff),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: loc.tr('confirm'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final staffProv = context.read<StaffProvider>();
                    await staffProv.inviteStaff(
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      role: role,
                      branchIds: selectedBranchIds,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final staffProv = context.watch<StaffProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('staffManagement')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(loc.tr('inviteStaff'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showInviteStaffSheet,
      ),
      body: RefreshIndicator(
        onRefresh: () => staffProv.fetchStaff(),
        color: AppTheme.primary,
        child: staffProv.staffList.isEmpty
            ? EmptyStateView(
                icon: Icons.people_outline,
                title: loc.isBangla ? 'কোনো স্টাফ নেই' : 'No Staff Members',
                message: loc.isBangla
                    ? 'আপনার ব্রাঞ্চ পরিচালনার জন্য নতুন স্টাফ বা ম্যানেজারকে আমন্ত্রণ জানান।'
                    : 'Invite managers and staff members to coordinate orders.',
                actionText: loc.tr('inviteStaff'),
                onAction: _showInviteStaffSheet,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staffProv.staffList.length,
                itemBuilder: (context, index) {
                  final member = staffProv.staffList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  member.email,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              member.role.displayName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
