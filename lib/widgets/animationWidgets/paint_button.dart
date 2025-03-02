import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class PaintButton extends StatelessWidget {
  const PaintButton({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    bool isPaintActive = sketchProvider.currentsketchMode == SketchMode.normal;

    return GestureDetector(
      onTap: () {
        sketchProvider.currentsketchMode = SketchMode.normal;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50, // Circular size
        height: 50,
        decoration: BoxDecoration(
          color: isPaintActive ? MyColors.pastelPeach : MyColors.deepBlue,
          shape: BoxShape.circle, // Makes it a perfect circle
          boxShadow: [
            if (isPaintActive)
              BoxShadow(
                color: MyColors.pastelPeach.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.brush,
              color: isPaintActive ? MyColors.deepBlue : MyColors.babyBlue,
              size: 26,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Icon(
                Icons.circle, // Paint droplet effect
                color: MyColors.pastelPeach,
                size: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
