import 'package:flutter/material.dart';

class PixelatedSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final Color color;

   PixelatedSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions, required this.label,
    Color?color
  }):color = color ?? Color(0xFF222222) , super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.0,
        activeTrackColor: color,
        inactiveTrackColor: Colors.white,

        thumbColor: color,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),

        overlayColor: color.withOpacity(0.12),
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