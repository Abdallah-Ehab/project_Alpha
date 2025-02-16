import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class PaintButton extends StatelessWidget {
  const PaintButton({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchPorvider = Provider.of<SketchProvider>(context);
    return IconButton(
      onPressed: () {
        sketchPorvider.currentsketchMode = SketchMode.normal;
      },
      icon: const Icon(
        Icons.brush,
        color: Colors.black,
      ),
    );
  }
}
