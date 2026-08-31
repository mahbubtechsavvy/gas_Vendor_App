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

  static String dayFromNumber(int dow) {
    switch (dow) {
      case 0:
        return 'SUNDAY';
      case 1:
        return 'MONDAY';
      case 2:
        return 'TUESDAY';
      case 3:
        return 'WEDNESDAY';
      case 4:
        return 'THURSDAY';
      case 5:
        return 'FRIDAY';
      case 6:
        return 'SATURDAY';
      default:
        return 'SATURDAY';
    }
  }

  static int dayToNumber(String dayName) {
    switch (dayName.toUpperCase()) {
      case 'SUNDAY':
        return 0;
      case 'MONDAY':
        return 1;
      case 'TUESDAY':
        return 2;
      case 'WEDNESDAY':
        return 3;
      case 'THURSDAY':
        return 4;
      case 'FRIDAY':
        return 5;
      case 'SATURDAY':
        return 6;
      default:
        return 6;
    }
  }

  factory DayHoursModel.fromJson(Map<String, dynamic> json) {
    String dayName = 'SATURDAY';
    if (json['dayOfWeek'] != null) {
      dayName = dayFromNumber(int.tryParse(json['dayOfWeek'].toString()) ?? 6);
    } else if (json['day_of_week'] != null) {
      final dowRaw = json['day_of_week'];
      if (dowRaw is int) {
        dayName = dayFromNumber(dowRaw);
      } else {
        dayName = dowRaw.toString().toUpperCase();
      }
    } else if (json['day'] != null) {
      final d = json['day'].toString();
      final numParsed = int.tryParse(d);
      if (numParsed != null) {
        dayName = dayFromNumber(numParsed);
      } else {
        dayName = d.toUpperCase();
      }
    }

    final open = json['opensAt'] ?? json['openTime'] ?? json['start_time'] ?? '09:00';
    final close = json['closesAt'] ?? json['closeTime'] ?? json['end_time'] ?? '21:00';
    final openBool = json['isEnabled'] ?? json['isOpen'] ?? json['is_enabled'] ?? true;

    return DayHoursModel(
      day: dayName,
      openTime: open.toString().length >= 5 ? open.toString().substring(0, 5) : open.toString(),
      closeTime: close.toString().length >= 5 ? close.toString().substring(0, 5) : close.toString(),
      isOpen: openBool == true || openBool == 1 || openBool == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayToNumber(day),
        'day': day,
        'isEnabled': isOpen,
        'isOpen': isOpen,
        'opensAt': openTime,
        'openTime': openTime,
        'closesAt': closeTime,
        'closeTime': closeTime,
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

  static const List<String> weekDaysSaturdayFirst = [
    'SATURDAY',
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY'
  ];

  OperatingHoursModel({required this.schedule});

  factory OperatingHoursModel.defaultSaturdayFirst() {
    return OperatingHoursModel(
      schedule: weekDaysSaturdayFirst
          .map((d) => DayHoursModel(
                day: d,
                openTime: '09:00',
                closeTime: '21:00',
                isOpen: true,
              ))
          .toList(),
    );
  }

  factory OperatingHoursModel.fromJson(List<dynamic> jsonList) {
    final parsed = jsonList
        .map((e) => DayHoursModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Reorder into standard Bangladesh week order: Saturday first
    final Map<String, DayHoursModel> map = {};
    for (var h in parsed) {
      map[h.day.toUpperCase()] = h;
    }

    final List<DayHoursModel> ordered = [];
    for (var dayName in weekDaysSaturdayFirst) {
      if (map.containsKey(dayName)) {
        ordered.add(map[dayName]!);
      } else {
        ordered.add(DayHoursModel(
          day: dayName,
          openTime: '09:00',
          closeTime: '21:00',
          isOpen: true,
        ));
      }
    }

    return OperatingHoursModel(schedule: ordered);
  }

  List<Map<String, dynamic>> toJson() => schedule.map((e) => e.toJson()).toList();
}
