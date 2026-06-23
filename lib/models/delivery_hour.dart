class DeliveryHour {
  final String dayOfWeek;
  final bool isEnabled;
  final String startTime;
  final String endTime;

  DeliveryHour({
    required this.dayOfWeek,
    required this.isEnabled,
    required this.startTime,
    required this.endTime,
  });

  factory DeliveryHour.fromJson(Map<String, dynamic> json) {
    return DeliveryHour(
      dayOfWeek: json['day_of_week'] ?? json['day'] ?? '',
      isEnabled:
          json['is_enabled'] == 1 ||
          json['is_enabled'] == true ||
          json['enabled'] == true,
      startTime: json['start_time'] ?? '09:00:00',
      endTime: json['end_time'] ?? '21:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': dayOfWeek,
      'enabled': isEnabled,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  DeliveryHour copyWith({
    String? dayOfWeek,
    bool? isEnabled,
    String? startTime,
    String? endTime,
  }) {
    return DeliveryHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
