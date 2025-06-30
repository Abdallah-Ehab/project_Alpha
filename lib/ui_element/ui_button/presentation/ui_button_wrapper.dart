import 'package:flutter/material.dart';

class UIButtonShell extends StatelessWidget {
  final Widget child;
  final String label;

  const UIButtonShell({super.key, required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        child,
      ],
    );
  }
}
