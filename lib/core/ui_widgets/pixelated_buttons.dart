import 'package:flutter/material.dart';

class PixelArtButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final double fontsize;

  const PixelArtButton({
    super.key,
    required this.text,

    required this.callback, required this.fontsize,
  }) : super();


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // so only the Ink’s decoration shows
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: callback,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              text,
              style:  TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: fontsize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}