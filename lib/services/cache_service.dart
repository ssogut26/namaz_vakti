import 'package:shared_preferences/shared_preferences.dart';

abstract class ICacheManager {
  Future<T> get<T>(String key);
  Future<bool> set<T>(String key, T value);
  Future<bool> remove(String key);
  Future<bool> clear();
}

class CacheManager extends ICacheManager {
  @override
  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  @override
  Future<T> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T;
  }

  @override
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  @override
  Future<bool> set<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      return prefs.setString(key, value);
    } else if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else if (value is List<String>) {
      return prefs.setStringList(key, value);
    } else if (value is List<List<String>>) {
      return prefs.setStringList(key, value.map((e) => e.join(',')).toList());
    } else {
      throw Exception('Invalid value type');
    }
  }
}
