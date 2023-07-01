import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/app.dart';

Future<void> main() async {
  await Hive.initFlutter();
  runApp(ProviderScope(child: NamazVaktiApp()));
}
