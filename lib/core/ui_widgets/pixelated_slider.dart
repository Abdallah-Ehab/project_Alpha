import 'package:flutter/material.dart';

class PixelatedSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;

  const PixelatedSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions, required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.0,
        activeTrackColor: const Color(0xFF222222),
        inactiveTrackColor: Colors.white,

        thumbColor: const Color(0xFF222222),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),

        overlayColor: const Color(0xFF222222).withOpacity(0.12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}