import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class EraserButton extends StatelessWidget {
  const EraserButton({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    return IconButton(
      onPressed: () {
        sketchProvider.currentsketchMode = SketchMode.eraser;
      },
      icon: const Icon(
        Icons.square_rounded,
        color: Colors.black,
      ),
    );
  }
}
