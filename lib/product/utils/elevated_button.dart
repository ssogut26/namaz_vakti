import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    required this.onPressed,
    required this.text,
    this.color,
    super.key,
  });

  final void Function()? onPressed;
  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: color == null
              ? const BorderRadius.all(
                  Radius.circular(16),
                )
              : BorderRadius.zero,
        ),
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
