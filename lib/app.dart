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
        scaffoldBackgroundColor: const Color(0xFFF9F5E3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F5E3),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: prefs.getString('latitude') != null ||
              prefs.getString('district') != null
          ? const HomeScreen()
          : const SelectionScreenView(),
    );
  }
}
