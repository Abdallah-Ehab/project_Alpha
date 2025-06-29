import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF222222),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.play_arrow, color: Colors.grey[300]),
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF222222),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.pause, color: Colors.grey[300]),
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF222222),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.square, color: Colors.grey[300]),
          ),
        ),
      ],
    );
  }
}