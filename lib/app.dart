import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/features/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/features/screens/selection/selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NamazVaktiApp extends StatelessWidget {
  const NamazVaktiApp({required this.prefs, super.key});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: AppConstants.lemonJuice,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.lemonJuice,
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
