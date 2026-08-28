import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/operating_hours_model.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/custom_button.dart';

class BranchDeliveryHoursScreen extends StatefulWidget {
  const BranchDeliveryHoursScreen({super.key});

  @override
  State<BranchDeliveryHoursScreen> createState() => _BranchDeliveryHoursScreenState();
}

class _BranchDeliveryHoursScreenState extends State<BranchDeliveryHoursScreen> {
  late List<DayHoursModel> _schedule;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final branch = context.read<BranchProvider>().selectedBranch;
      if (branch?.operatingHours != null && branch!.operatingHours!.schedule.isNotEmpty) {
        _schedule = List.from(branch.operatingHours!.schedule);
      } else {
        _schedule = OperatingHoursModel.defaultSaturdayFirst().schedule;
      }
      _isInitialized = true;
    }
  }

  Future<void> _selectTime(int index, bool isStartTime) async {
    final currentStr = isStartTime ? _schedule[index].openTime : _schedule[index].closeTime;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '00') ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _schedule[index] = _schedule[index].copyWith(openTime: formatted);
        } else {
          _schedule[index] = _schedule[index].copyWith(closeTime: formatted);
        }
      });
    }
  }

  void _save() async {
    final branchProv = context.read<BranchProvider>();
    final loc = context.read<LocaleProvider>();
    final success = await branchProv.saveOperatingHours(OperatingHoursModel(schedule: _schedule));

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isBangla ? 'ডেলিভারি সময়সূচি সফলভাবে সংরক্ষিত হয়েছে' : 'Operating schedule saved successfully',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (branchProv.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(branchProv.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final branchProv = context.watch<BranchProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('deliveryHours')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _schedule.length,
                itemBuilder: (context, index) {
                  final day = _schedule[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: day.isOpen ? AppTheme.success : AppTheme.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.isBangla ? day.displayBangla : day.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              Switch(
                                value: day.isOpen,
                                activeTrackColor: AppTheme.success,
                                onChanged: (val) {
                                  setState(() {
                                    _schedule[index] = day.copyWith(isOpen: val);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (day.isOpen) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.access_time, size: 16),
                                    label: Text('Open: ${day.openTime}'),
                                    onPressed: () => _selectTime(index, true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.access_time_filled, size: 16),
                                    label: Text('Close: ${day.closeTime}'),
                                    onPressed: () => _selectTime(index, false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: CustomButton(
                text: loc.tr('saveHours'),
                isLoading: branchProv.isLoading,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
