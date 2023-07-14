import 'package:flutter/material.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';

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
        title: Text(LocaleKeys.noConnection_title.locale),
      ),
      body: Center(
        child: Text(LocaleKeys.noConnection_message.locale),
      ),
    );
  }
}
