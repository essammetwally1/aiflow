import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const _rememberKey = 'remember_me';

  static Future<bool> isRememberMeEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_rememberKey) ?? false;
  }

  static Future<void> setRememberMe(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_rememberKey, value);
  }
}
