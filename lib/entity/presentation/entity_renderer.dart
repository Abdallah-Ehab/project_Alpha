import 'dart:developer';

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
      
      animationWidget = Container(
        width: entity.width,
        height: entity.height,
        color: Colors.blue,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Visualize entity canvas
        Positioned(
          top: 0,
          left: 0,
          child: animationWidget),
        if (colliderComponent != null)
          ChangeNotifierProvider.value(
            value: colliderComponent,
            child: Consumer<ColliderComponent>(
              builder: (context, value, child) {
                log('collider component width is ${colliderComponent.width}');
                return Positioned(
                top: 0, // Align collider to entity's top-left
                left: 0,
                child: ColliderWidget(
                  width: colliderComponent.width,
                  height: colliderComponent.height,
                ),
              );
  }),
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

    // Calculate scaling factors from animation editor size (600x600) to entity size
    const double editorWidth = 600.0;
    const double editorHeight = 600.0;
    double scaleX = size.width / editorWidth;
    double scaleY = size.height / editorHeight;

    for (var sketch in sketches) {
      for (int i = 0; i < sketch.points.length - 1; i++) {
        // Scale the points from editor coordinates to entity coordinates
        Offset scaledPoint1 = Offset(
          sketch.points[i].dx * scaleX,
          sketch.points[i].dy * scaleY,
        );
        Offset scaledPoint2 = Offset(
          sketch.points[i + 1].dx * scaleX,
          sketch.points[i + 1].dy * scaleY,
        );

        canvas.drawLine(
          scaledPoint1,
          scaledPoint2,
          Paint()
            ..color = sketch.color
            ..strokeWidth = sketch.strokeWidth * scaleX // Scale stroke width too
            ..style = PaintingStyle.stroke
        );
      }
    }
    
    if (keyFrame.image != null) {
      
      canvas.drawImage(
        keyFrame.image!, 
        Offset((-size.width / 8), 0), 
        Paint()
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
