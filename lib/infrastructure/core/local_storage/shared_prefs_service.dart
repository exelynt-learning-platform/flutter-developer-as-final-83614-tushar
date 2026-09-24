import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  static const String _employeeCacheKey = 'employee_cache';

  Future<void> cacheEmployeeList(String jsonString) async {
    await _prefs.setString(_employeeCacheKey, jsonString);
  }

  String? getCachedEmployeeList() {
    return _prefs.getString(_employeeCacheKey);
  }

  Future<void> clearEmployeeCache() async {
    await _prefs.remove(_employeeCacheKey);
  }
}
