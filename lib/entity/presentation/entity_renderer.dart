import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_widget.dart';

class EntityRenderer extends StatelessWidget {
  final Entity entity;
  const EntityRenderer({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final animationController = entity.getComponent<AnimationControllerComponent>();
    final colliderComponent = entity.getComponent<ColliderComponent>();

    // Default keyFrame for entities without animation
    KeyFrame defaultKeyFrame = KeyFrame(
      sketches: [],
      position: Offset.zero,
      rotation: 0,
      scale: 1.0,
    );

    Widget animationWidget;
    if (animationController != null) {
      animationWidget = ChangeNotifierProvider.value(
        value: animationController,
        child: Consumer<AnimationControllerComponent>(
          builder: (context, value, child) {
            final frames = animationController
                .animationTracks[animationController.currentAnimationTrack.name]?.frames;

            final keyFrame = (frames != null && frames.isNotEmpty)
                ? frames[animationController.currentFrame]
                : KeyFrame(
                    sketches: [
                      SketchModel(
                        points: [const Offset(100, 100), const Offset(100, 200)],
                        color: Colors.black,
                        strokeWidth: 1.5,
                      ),
                    ],
                  );

            return CustomPaint(
              painter: EntityPainter(keyFrame: keyFrame),
              size: Size(entity.width, entity.height),
            );
          },
        ),
      );
    } else {
      
      animationWidget = CustomPaint(
        painter: EntityPainter(keyFrame: defaultKeyFrame),
        size: Size(entity.width, entity.height),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Visualize entity canvas
        Container(
          width: entity.width,
          height: entity.height,
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        animationWidget,
        if (colliderComponent != null)
          ChangeNotifierProvider.value(
            value: colliderComponent,
            child: Consumer<ColliderComponent>(
              builder: (context, value, child) => Positioned(
                top: 0, // Align collider to entity's top-left
                left: 0,
                child: ColliderWidget(
                  width: colliderComponent.width,
                  height: colliderComponent.height,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EntityPainter extends CustomPainter {
  KeyFrame keyFrame;
  EntityPainter({required this.keyFrame});

  @override
  void paint(Canvas canvas, Size size) {
    if (keyFrame.sketches.isEmpty && keyFrame.image == null) {
      return;
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.grey);
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
      canvas.drawImage(keyFrame.image!, Offset(-size.width / 8, 0), Paint());
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}