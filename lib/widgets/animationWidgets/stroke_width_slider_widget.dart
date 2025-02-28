import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/constants/colors/colors.dart'; // Assuming deepBlue is defined here
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class StrokeWidthSliderWidget extends StatelessWidget {
  const StrokeWidthSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    double iconSize = 10 + (sketchProvider.currentStrokeWidth / 2); // Scale dynamically

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Stroke Width",
          style: TextStyle(
            color: MyColors.pastelPeach, // White for contrast
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: MyColors.deepBlue, // Themed Deep Blue background
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200), // Smooth transition
                curve: Curves.easeOut,
                child: Icon(
                  Icons.brush_outlined,
                  color: MyColors.pastelPeach,
                  size: iconSize, // Dynamically change size
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: MyColors.babyBlue, 
                    inactiveTrackColor: Colors.grey.withOpacity(0.4),
                    thumbColor: MyColors.pastelPeach,
                    overlayColor: MyColors.pastelPeach.withOpacity(0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    min: 1.0,
                    max: 50,
                    divisions: 20,
                    value: sketchProvider.currentStrokeWidth,
                    onChanged: (value) {
                      sketchProvider.currentStrokeWidth = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
