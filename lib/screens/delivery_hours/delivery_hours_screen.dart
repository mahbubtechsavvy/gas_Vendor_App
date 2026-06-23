import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/delivery_service.dart';

class DeliveryHoursScreen extends StatefulWidget {
  const DeliveryHoursScreen({super.key});

  @override
  State<DeliveryHoursScreen> createState() => _DeliveryHoursScreenState();
}

class _DeliveryHoursScreenState extends State<DeliveryHoursScreen> {
  final List<String> _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  bool _isLoading = true;
  bool _isSaving = false;

  // Day status (enabled/disabled)
  final Map<String, bool> _dayStatus = {};

  // Start times
  final Map<String, TimeOfDay> _startTimes = {};

  // End times
  final Map<String, TimeOfDay> _endTimes = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    _loadDeliveryHours();
  }

  void _initializeDefaults() {
    for (var day in _days) {
      _dayStatus[day] = true;
      _startTimes[day] = const TimeOfDay(hour: 9, minute: 0);
      _endTimes[day] = const TimeOfDay(hour: 21, minute: 0);
    }
  }

  Future<void> _loadDeliveryHours() async {
    setState(() => _isLoading = true);

    try {
      final hours = await DeliveryService.getDeliveryHours();

      if (hours.isNotEmpty) {
        for (var hour in hours) {
          final day = hour['day_of_week'] ?? hour['day'];
          if (day != null && _days.contains(day)) {
            _dayStatus[day] =
                hour['is_enabled'] == true || hour['is_enabled'] == 1;
            _startTimes[day] = _parseTime(hour['start_time'] ?? '9:00 AM');
            _endTimes[day] = _parseTime(hour['end_time'] ?? '9:00 PM');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading delivery hours: $e');
    }

    setState(() => _isLoading = false);
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      // Handle 12-hour format like "9:30 AM" or "10:30 PM"
      timeStr = timeStr.trim().toUpperCase();

      final isPM = timeStr.contains('PM');
      final isAM = timeStr.contains('AM');

      // Remove AM/PM
      timeStr = timeStr.replaceAll('AM', '').replaceAll('PM', '').trim();

      // Handle HH:MM:SS or HH:MM format
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      // Convert to 24-hour for TimeOfDay if needed
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeForApi(TimeOfDay time) {
    // Format as 12-hour AM/PM for API
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Delivery Hours', style: ThemeConfig.heading3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(ThemeConfig.spaceLG),
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      return _buildDayRow(day);
                    },
                  ),
                ),
                // Update Button
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spaceLG),
                  decoration: BoxDecoration(
                    color: ThemeConfig.cardWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDeliveryHours,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.darkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeConfig.spaceLG,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConfig.radiusMedium,
                          ),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text('Update Hours', style: ThemeConfig.buttonText),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDayRow(String day) {
    final isEnabled = _dayStatus[day] ?? false;
    final startTime = _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
    final endTime = _endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConfig.spaceMD),
      padding: const EdgeInsets.all(ThemeConfig.spaceMD),
      decoration: BoxDecoration(
        color: ThemeConfig.cardWhite,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(
          color: isEnabled
              ? ThemeConfig.inStock.withValues(alpha: 0.3)
              : ThemeConfig.borderColor,
        ),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Column(
        children: [
          // Day Name and Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: ThemeConfig.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dayStatus[day] = value;
                    });
                  },
                  activeThumbColor: ThemeConfig.inStock,
                  activeTrackColor: ThemeConfig.inStock.withValues(alpha: 0.5),
                  inactiveThumbColor: ThemeConfig.outOfStock,
                  inactiveTrackColor: ThemeConfig.outOfStock.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // Time Selection Row
          if (isEnabled) ...[
            const SizedBox(height: ThemeConfig.spaceSM),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Start',
                    time: startTime,
                    onTap: () => _selectTime(day, true),
                  ),
                ),
                const SizedBox(width: ThemeConfig.spaceMD),
                Expanded(
                  child: _buildTimeSelector(
                    label: 'End',
                    time: endTime,
                    onTap: () => _selectTime(day, false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeConfig.captionText.copyWith(
            color: ThemeConfig.textLight,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeConfig.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeConfig.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimeForDisplay(time),
                  style: ThemeConfig.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.textPrimary,
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: ThemeConfig.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeForDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(String day, bool isStartTime) async {
    final currentTime = isStartTime ? _startTimes[day] : _endTimes[day];

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeConfig.primaryBlue,
              onPrimary: Colors.white,
              surface: ThemeConfig.cardWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTimes[day] = picked;
        } else {
          _endTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _saveDeliveryHours() async {
    setState(() => _isSaving = true);

    // Prepare data for API
    final deliveryHours = _days.map((day) {
      return {
        'day': day,
        'enabled': _dayStatus[day] ?? false,
        'start_time': _formatTimeForApi(
          _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
        ),
        'end_time': _formatTimeForApi(
          _endTimes[day] ?? const TimeOfDay(hour: 21, minute: 0),
        ),
      };
    }).toList();

    debugPrint('Saving delivery hours: $deliveryHours');

    final success = await DeliveryService.updateDeliveryHours(deliveryHours);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Delivery hours updated successfully'
                : 'Failed to update delivery hours',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
