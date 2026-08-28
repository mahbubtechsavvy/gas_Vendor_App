import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/rider_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';

class RiderManagementScreen extends StatefulWidget {
  const RiderManagementScreen({super.key});

  @override
  State<RiderManagementScreen> createState() => _RiderManagementScreenState();
}

class _RiderManagementScreenState extends State<RiderManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderProvider>().fetchRiders();
    });
  }

  void _showAddRiderSheet() {
    final loc = context.read<LocaleProvider>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                loc.tr('addRider'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: loc.tr('riderName'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.tr('riderPhone'),
                  prefixIcon: const Icon(Icons.phone_android),
                ),
                validator: (val) => val == null || val.trim().length < 11 ? 'Valid phone number required' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: loc.tr('save'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  final riderProv = context.read<RiderProvider>();
                  await riderProv.addRider(
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final riderProv = context.watch<RiderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('riders')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(loc.tr('addRider'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showAddRiderSheet,
      ),
      body: RefreshIndicator(
        onRefresh: () => riderProv.fetchRiders(),
        color: AppTheme.primary,
        child: riderProv.riders.isEmpty
            ? EmptyStateView(
                icon: Icons.delivery_dining,
                title: loc.isBangla ? 'কোনো রাইডার নেই' : 'No Delivery Riders',
                message: loc.isBangla
                    ? 'আপনার ব্রাঞ্চের ডেলিভারির জন্য নতুন রাইডার যোগ করুন।'
                    : 'Add riders to assign them to incoming customer delivery orders.',
                actionText: loc.tr('addRider'),
                onAction: _showAddRiderSheet,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: riderProv.riders.length,
                itemBuilder: (context, index) {
                  final rider = riderProv.riders[index];
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
                            child: const Icon(Icons.delivery_dining, color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rider.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rider.phone,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (rider.phone.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone, color: AppTheme.success),
                              onPressed: () => launchUrl(Uri.parse('tel:${rider.phone}')),
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
