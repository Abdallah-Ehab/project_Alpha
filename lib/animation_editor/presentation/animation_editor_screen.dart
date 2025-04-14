import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';


class AnimationEditorScreen extends StatelessWidget {
  const AnimationEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(builder: (context, activeEntity, child) {
      var animationComponent =
          activeEntity.getComponent<AnimationControllerComponent>();
      if (animationComponent == null) {
        return const Center(child: Text("No animation component"));
      } else {
        return ChangeNotifierProvider.value(
          value: animationComponent,
          child: Consumer<AnimationControllerComponent>(
            builder: (context, animComponent, child) {
              var currentFrame =
                  animComponent.currentAnimationTrack.frames.isNotEmpty
                      ? animComponent.currentAnimationTrack
                          .frames[animComponent.currentFrame]
                      : null;
              return GestureDetector(
                onPanStart: (details) {
                  if (currentFrame != null) {
                    var newSketch = SketchModel(
                        points: [details.localPosition],
                        color: Colors.black,
                        strokeWidth: 1.0);
                    currentFrame.addSketch(newSketch);
                  }
                },
                onPanUpdate: (details) {
                  if (currentFrame != null &&
                      currentFrame.sketches.isNotEmpty) {
                    currentFrame.addPointToCurrentSketch(details.localPosition);
                  }
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width,
                  child: currentFrame != null
                      ? ChangeNotifierProvider.value(
                          value: currentFrame,
                          child: Consumer<KeyFrame>(
                            builder: (context, keyFrame, child) {
                              return CustomPaint(
                                painter: AnimationPainter(keyFrame: keyFrame),
                                size: const Size(500, 500),
                              );
                            },
                          ),
                        )
                      : const Center(child: Text("No frame")),
                ),
              );
            },
          ),
        );
      }
    });
  }
}

class AnimationPainter extends CustomPainter {
  KeyFrame keyFrame;
  AnimationPainter({
    required this.keyFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
