import 'package:flutter_test/flutter_test.dart';
import 'package:vendorapp/models/operating_hours_model.dart';

void main() {
  group('Branch Saturday-First Operating Hours Model Tests (BR-025)', () {
    test('Default schedule begins with Saturday and covers all 7 days', () {
      final hours = OperatingHoursModel.defaultSaturdayFirst();

      expect(hours.schedule.length, 7);
      expect(hours.schedule[0].day, 'SATURDAY');
      expect(hours.schedule[1].day, 'SUNDAY');
      expect(hours.schedule[2].day, 'MONDAY');
      expect(hours.schedule[3].day, 'TUESDAY');
      expect(hours.schedule[4].day, 'WEDNESDAY');
      expect(hours.schedule[5].day, 'THURSDAY');
      expect(hours.schedule[6].day, 'FRIDAY');
    });

    test('Serializes and deserializes schedule cleanly', () {
      final defaultHours = OperatingHoursModel.defaultSaturdayFirst();
      final json = defaultHours.toJson();

      final reconstructed = OperatingHoursModel.fromJson(json);

      expect(reconstructed.schedule.length, 7);
      expect(reconstructed.schedule.first.day, 'SATURDAY');
      expect(reconstructed.schedule.first.openTime, '08:00');
      expect(reconstructed.schedule.first.closeTime, '20:00');
      expect(reconstructed.schedule.first.isOpen, isTrue);
    });

    test('DayHoursModel supports copyWith for time changes', () {
      final saturday = DayHoursModel(
        day: 'SATURDAY',
        openTime: '08:00',
        closeTime: '20:00',
        isOpen: true,
      );

      final updated = saturday.copyWith(
        openTime: '09:30',
        closeTime: '22:00',
        isOpen: false,
      );

      expect(updated.day, 'SATURDAY');
      expect(updated.openTime, '09:30');
      expect(updated.closeTime, '22:00');
      expect(updated.isOpen, isFalse);
    });
  });
}
