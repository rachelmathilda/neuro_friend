import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsService {
  static const _keyName = 'user_name';

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'friend';
  }

  static Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }
}
