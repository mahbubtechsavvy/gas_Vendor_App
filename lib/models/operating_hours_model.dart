class DayHoursModel {
  final String day; // SATURDAY, SUNDAY, etc.
  final String openTime; // "09:00"
  final String closeTime; // "21:00"
  final bool isOpen;

  DayHoursModel({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  factory DayHoursModel.fromJson(Map<String, dynamic> json) {
    return DayHoursModel(
      day: json['day']?.toString().toUpperCase() ?? 'SATURDAY',
      openTime: json['openTime'] ?? '09:00',
      closeTime: json['closeTime'] ?? '21:00',
      isOpen: json['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'openTime': openTime,
        'closeTime': closeTime,
        'isOpen': isOpen,
      };

  String get displayName {
    switch (day.toUpperCase()) {
      case 'SATURDAY':
        return 'Saturday';
      case 'SUNDAY':
        return 'Sunday';
      case 'MONDAY':
        return 'Monday';
      case 'TUESDAY':
        return 'Tuesday';
      case 'WEDNESDAY':
        return 'Wednesday';
      case 'THURSDAY':
        return 'Thursday';
      case 'FRIDAY':
        return 'Friday';
      default:
        return day;
    }
  }

  String get displayBangla {
    switch (day.toUpperCase()) {
      case 'SATURDAY':
        return 'শনিবার';
      case 'SUNDAY':
        return 'রবিবার';
      case 'MONDAY':
        return 'সোমবার';
      case 'TUESDAY':
        return 'মঙ্গলবার';
      case 'WEDNESDAY':
        return 'বুধবার';
      case 'THURSDAY':
        return 'বৃহস্পতিবার';
      case 'FRIDAY':
        return 'শুক্রবার';
      default:
        return day;
    }
  }

  DayHoursModel copyWith({
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return DayHoursModel(
      day: day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class OperatingHoursModel {
  final List<DayHoursModel> schedule;

  OperatingHoursModel({required this.schedule});

  factory OperatingHoursModel.defaultSaturdayFirst() {
    const days = [
      'SATURDAY',
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY'
    ];
    return OperatingHoursModel(
      schedule: days
          .map((d) => DayHoursModel(
                day: d,
                openTime: '08:00',
                closeTime: '20:00',
                isOpen: true,
              ))
          .toList(),
    );
  }

  factory OperatingHoursModel.fromJson(List<dynamic> jsonList) {
    return OperatingHoursModel(
      schedule: jsonList.map((e) => DayHoursModel.fromJson(e)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() => schedule.map((e) => e.toJson()).toList();
}
