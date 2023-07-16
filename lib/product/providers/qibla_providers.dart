import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qiblaProvider = StreamProvider.autoDispose<QiblahDirection>((ref) {
  FlutterQiblah.requestPermissions();
  FlutterQiblah.androidDeviceSensorSupport();
  return FlutterQiblah.qiblahStream;
});
