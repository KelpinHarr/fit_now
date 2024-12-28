import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static const String _LOGIN_STATUS = 'login_status';
  static const String _LOGIN_TIMESTAMP = 'login_timestamp';
  // static const String _USER_ROLE = 'user_role';
  static const String _USER_EMAIL = 'user_email';

  static Future<void> setLoginStatus(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_LOGIN_STATUS, true);
    await prefs.setString('user_name', name);
    // await prefs.setString(_USER_ROLE, role);String role, 
    await prefs.setString(_USER_EMAIL, email);
    await prefs.setInt(_LOGIN_TIMESTAMP, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_LOGIN_STATUS) ?? false;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? "";
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_USER_EMAIL) ?? "";
  }

  // static Future<String?> getUserRole() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_USER_ROLE) ?? "";
  // }

  static Future<void> clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_LOGIN_STATUS);
    await prefs.remove('user_name');
    await prefs.remove(_USER_EMAIL);
    // await prefs.remove(_USER_ROLE);
    await prefs.remove(_LOGIN_TIMESTAMP);
  }

  static Future<bool> isLoginExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt(_LOGIN_TIMESTAMP) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final duration = Duration(milliseconds: currentTime - loginTimestamp);
    return duration.inDays >= 7;
  }
}