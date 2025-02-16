import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';


class StrokeWidthSliderWidget extends StatelessWidget {
  const StrokeWidthSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    return Slider(
      label: "Stroke Width",
      min: 1.0,
      max: 50,
      divisions: 20,
      value: sketchProvider.currentStrokeWidth,
      onChanged: (value) {
        sketchProvider.currentStrokeWidth = value;
      },
    );
  }
}
