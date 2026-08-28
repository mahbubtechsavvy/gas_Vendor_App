import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import 'app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'bn';
  final StorageService _storage = StorageService();

  String get locale => _locale;
  bool get isBangla => _locale == 'bn';

  LocaleProvider() {
    _locale = _storage.getLocale();
  }

  Future<void> setLocale(String newLocale) async {
    if (newLocale != 'en' && newLocale != 'bn') return;
    _locale = newLocale;
    await _storage.setLocale(newLocale);
    notifyListeners();
  }

  String tr(String key) {
    final values = AppStrings.localizedValues[_locale];
    if (values != null && values.containsKey(key)) {
      return values[key]!;
    }
    return AppStrings.localizedValues['en']?[key] ?? key;
  }
}
