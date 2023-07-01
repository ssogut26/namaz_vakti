import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';

class NamazVaktiApp extends StatelessWidget {
  NamazVaktiApp({super.key});

  final locationBox = Hive.box('locationBox');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: locationBox.get('positon') != null
          ? const HomeScreen()
          : const LocationSelectionScreen(),
    );
  }
}
