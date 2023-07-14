import 'package:hive_flutter/hive_flutter.dart';

abstract class ICacheManager<T> {
  ICacheManager(this.key);
  final String key;
  Box<T>? _box;

  Future<void> init() async {
    registerAdapters();
    if (!(_box?.isOpen ?? false)) {
      _box = await Hive.openBox<T>(key);
    }
  }

  void registerAdapters();

  Future<void> clearAll() async {
    await _box?.clear();
  }

  Future<void> addItems(List<T> items);
  Future<void> putItems(List<T> items);

  T? getItem(String key);
  List<T>? getValues();

  Future<void> putItem(String key, T item);
  Future<void> removeItem(String key);
}
