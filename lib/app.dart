import 'package:flutter/material.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/selection/selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NamazVaktiApp extends StatelessWidget {
  const NamazVaktiApp({required this.prefs, super.key});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: prefs.getString('latitude') != null ||
              prefs.getString('district') != null
          ? const HomeScreen()
          : const SelectionScreenView(),
    );
  }
}
