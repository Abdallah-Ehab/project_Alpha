import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/onin_skin_settings.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationEditorScreen extends StatelessWidget {
  const AnimationEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onion = context.watch<OnionSkinSettings>();

    return Scaffold(
      body: Consumer<Entity>(builder: (context, activeEntity, child) {
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
                      final tool = context.read<ToolSettings>();
                      final sketch = SketchModel(
                        points: [details.localPosition],
                        color: tool.isEraser
                            ? Colors.transparent
                            : tool.currentColor,
                        strokeWidth: tool.strokeWidth,
                      );
                      currentFrame.addSketch(sketch);
                    }
                  },
                  onPanUpdate: (details) {
                    if (currentFrame == null) return;
                    final tool = context.read<ToolSettings>();

                    if (tool.isEraser) {
                      currentFrame.removePointFromSketch(details.localPosition);
                    } else if (currentFrame.sketches.isNotEmpty) {
                      currentFrame
                          .addPointToCurrentSketch(details.localPosition);
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
                                  painter: AnimationPainter(
                                    frames: animComponent
                                        .currentAnimationTrack.frames,
                                    currentIndex: animComponent.currentFrame,
                                    prevFrames:
                                        onion.enabled ? onion.prevFrames : 0,
                                    nextFrames:
                                        onion.enabled ? onion.nextFrames : 0,
                                  ),
                                  size: const Size(600, 600),
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
      }),
    );
  }
}

class AnimationPainter extends CustomPainter {
  final List<KeyFrame> frames;
  final int currentIndex;
  final int prevFrames;
  final int nextFrames;

  AnimationPainter({
    required this.frames,
    required this.currentIndex,
    required this.prevFrames,
    required this.nextFrames,
  });

  @override
  void paint(Canvas canvas, Size size) {

    // Draw gray background
  canvas.drawRect(
    Offset.zero & size,
    Paint()..color = Colors.grey[300]!,
  );


    // Paint previous frames
    for (int i = 1; i <= prevFrames; i++) {
      int index = currentIndex - i;
      if (index >= 0) {
        _paintFrame(canvas, frames[index], Colors.red.withAlpha(100),size);
      }
    }

    // Paint next frames
    for (int i = 1; i <= nextFrames; i++) {
      int index = currentIndex + i;
      if (index < frames.length) {
        _paintFrame(canvas, frames[index], Colors.green.withAlpha(100),size);
      }
    }

    // Paint current frame normally
    _paintFrame(canvas, frames[currentIndex], null,size);
  }

  void _paintFrame(Canvas canvas, KeyFrame keyFrame, Color? overrideColor,Size size) {
    canvas.save();
    canvas.translate(keyFrame.position.dx, keyFrame.position.dy);
    canvas.rotate(keyFrame.rotation);
    canvas.scale(keyFrame.scale);

    for (var sketch in keyFrame.sketches) {
      for (int i = 0; i < sketch.points.length - 1; i++) {
        canvas.drawLine(
          sketch.points[i],
          sketch.points[i + 1],
          Paint()
            ..color = overrideColor ?? sketch.color
            ..strokeWidth = sketch.strokeWidth
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (keyFrame.image != null) {
      canvas.drawImage(
        keyFrame.image!,
        Offset(size.width/2,size.height/2),
        Paint()..color = overrideColor ?? Colors.white,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
