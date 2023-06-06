import 'package:flutter/material.dart';
import 'package:namaz_vakti/screens/location_selection.dart';

class NamazVaktiApp extends StatelessWidget {
  const NamazVaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LocationSelectionScreen(),
    );
  }
}
