import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class EntityRenderer extends StatelessWidget {
  final Entity entity;
  const EntityRenderer({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    var animationController =
        entity.getComponent<AnimationControllerComponent>();
    if (animationController == null) {
      return const Center(child: Text("No animation component"));
    } else {
      return ChangeNotifierProvider.value(
        value: animationController,
        child: Consumer<AnimationControllerComponent>(
          builder: (context, value, child) {
            return CustomPaint(
                painter: EntityPainter(
                    keyFrame:animationController
                        .animationTracks[
                            animationController.currentAnimationTrack.name]!
                        .frames.isNotEmpty ? animationController
                        .animationTracks[
                            animationController.currentAnimationTrack.name]!
                        .frames[animationController.currentFrame] : KeyFrame(sketches: [SketchModel(points: [const Offset(100,100),const Offset(100,200)], color: Colors.black, strokeWidth: 1.5)])),
                size: const Size(500, 500));
          },
        ),
      );
    }
  }
}

class EntityPainter extends CustomPainter {
  KeyFrame keyFrame;
  EntityPainter({
    required this.keyFrame,
  });

  

  @override
  void paint(Canvas canvas, Size size) {
    if(keyFrame.sketches.isEmpty && keyFrame.image == null){
    return;
  }
    var sketches = keyFrame.sketches;
    canvas.save();
    canvas.translate(keyFrame.position.dx, keyFrame.position.dy);
    canvas.rotate(keyFrame.rotation);
    canvas.scale(keyFrame.scale);

    for (var sketch in sketches) {
      for (int i = 0; i < sketch.points.length - 1; i++) {
        canvas.drawLine(
            sketch.points[i],
            sketch.points[i + 1],
            Paint()
              ..color = sketch.color
              ..strokeWidth = sketch.strokeWidth
              ..style = PaintingStyle.stroke);
      }
    }
    if (keyFrame.image != null) {
      canvas.drawImage(
          keyFrame.image!, Offset(size.width / 2, size.height / 2), Paint());
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// class EntityPainter extends CustomPainter {
//   final Entity entity;

//   EntityPainter(this.entity);

//   @override
//   void paint(Canvas canvas, Size size) {
//     var animationController = entity.getComponent<AnimationControllerComponent>();
//     if (animationController == null) return;
    
//     var currentTrack = animationController.animationTracks[animationController.currentAnimationTrackName];
//     if (currentTrack == null || currentTrack.frames.isEmpty) return;
    
//     var frame = currentTrack.frames[animationController.currentFrame];
    
    
//     paintImage(
//       canvas: canvas,
//       rect: Rect.fromLTWH(0, 0, size.width, size.height),
//       image: frame.image,
//       fit: BoxFit.contain,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
