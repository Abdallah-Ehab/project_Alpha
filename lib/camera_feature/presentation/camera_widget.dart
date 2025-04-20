import 'package:flutter/material.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Fixed size for the camera marker
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        color: Colors.transparent,
      ),
    );
  }
}