import 'package:shared_preferences/shared_preferences.dart';

// Keys (mirrors localStorage keys from the JS app)
class StorageKeys {
  static const body = 'kelly_body';
  static const saved = 'kelly_saved';
  static const settings = 'kelly_settings';
  static const water = 'kelly_water';
  static const progress = 'kelly_progress';
  static const streak = 'kelly_streak';
  static const energy = 'kelly_energy';
  static const location = 'kelly_location';
  static const avatar = 'kelly_avatar';
  static const onboarding = 'fitpilot_onboarding_v1';
}

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    assert(_prefs != null, 'StorageService.init() must be called first');
    return _prefs!;
  }

  static String? getString(String key) => prefs.getString(key);

  static Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);

  static Future<bool> remove(String key) => prefs.remove(key);

  static Future<bool> clear() => prefs.clear();
}
