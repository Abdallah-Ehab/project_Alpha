import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class EraserButton extends StatelessWidget {
  const EraserButton({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    bool isEraserActive = sketchProvider.currentsketchMode == SketchMode.eraser;

    return GestureDetector(
      onTap: () {
        sketchProvider.currentsketchMode = SketchMode.eraser;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50, // Matches Paint Button
        height: 50,
        decoration: BoxDecoration(
          color: isEraserActive ? MyColors.pastelPeach : MyColors.deepBlue,
          shape: BoxShape.circle, // Ensures a rounded button
          boxShadow: [
            if (isEraserActive)
              BoxShadow(
                color: MyColors.pastelPeach.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.rectangle_outlined, // Triangle shape resembles an eraser
              color: isEraserActive ? MyColors.deepBlue : MyColors.pastelPeach,
              size: 28,
            ),
            Positioned(
              bottom: 10,
              child: Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: MyColors.babyBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
