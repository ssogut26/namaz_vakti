import 'package:flutter/material.dart';

class NoConnectionScreenView extends StatefulWidget {
  const NoConnectionScreenView({super.key});

  @override
  State<NoConnectionScreenView> createState() => _NoConnectionScreenViewState();
}

class _NoConnectionScreenViewState extends State<NoConnectionScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Connection'),
      ),
      body: const Center(
        child: Text('No Connection'),
      ),
    );
  }
}
