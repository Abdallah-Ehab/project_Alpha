import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/light_entity.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_widget.dart';



class EntityRenderer extends StatelessWidget {
  final Entity entity;
  final List<Entity> lights;
  const EntityRenderer({super.key, required this.entity, required this.lights});

  @override
  Widget build(BuildContext context) {
    final animationController =
        entity.getComponent<AnimationControllerComponent>();
    final colliderComponent = entity.getComponent<ColliderComponent>();

    Widget animationWidget;
    if (animationController != null) {
      animationWidget = ChangeNotifierProvider.value(
        value: animationController,
        child: Consumer<AnimationControllerComponent>(
          builder: (context, value, child) {
            final frames = animationController
                .animationTracks[animationController.currentAnimationTrack.name]
                ?.frames;

            final keyFrame = (frames != null && frames.isNotEmpty)
                ? frames[animationController.currentFrame]
                : KeyFrame(
                    sketches: [
                      SketchModel(
                        points: [
                          const Offset(100, 100),
                          const Offset(100, 200)
                        ],
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
      if (entity is LightEntity) {
        animationWidget = Container(
          width: entity.width,
          height: entity.height,
          decoration: BoxDecoration(
            color: (entity as LightEntity).color,
            shape: BoxShape.circle,
          ),
        );
      } else {
        animationWidget = Container(
          width: entity.width,
          height: entity.height,
          color: Colors.blue,
        );
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Visualize entity canvas
        Positioned(
          top: entity.position.dy,
          left: entity.position.dx,
          child: LightingConsumer(
              entity: entity, lights: lights, child: animationWidget),
        ),
        if (colliderComponent != null)
          ChangeNotifierProvider.value(
            value: colliderComponent,
            child: Consumer<ColliderComponent>(
              builder: (context, value, child) {
                log('collider component width is ${colliderComponent.width}');
                return Positioned(
                  top: entity.position.dy + colliderComponent.position.dy,
                  left: entity.position.dx + colliderComponent.position.dx,
                  child: ColliderWidget(
                    width: colliderComponent.width,
                    height: colliderComponent.height,
                  ),
                );
              },
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
              ..strokeWidth =
                  sketch.strokeWidth * scaleX // Scale stroke width too
              ..style = PaintingStyle.stroke);
      }
    }

    if (keyFrame.image != null) {
      canvas.drawImageRect(
          keyFrame.image!,
          Rect.fromLTWH(0, 0, keyFrame.image!.width.toDouble(),
              keyFrame.image!.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..filterQuality = FilterQuality.high);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Widget applyLightingToEntity({
  required Widget child,
  required Entity entity,
  required List<Entity> lights,
}) {
  if (entity is LightEntity) return child; // Don't light the lights themselves

  Offset entityCenter = Offset(
    entity.position.dx + entity.width / 2,
    entity.position.dy + entity.height / 2,
  );

  Color finalLightColor = Colors.transparent;

  for (var lightEntity in lights) {
    if (lightEntity is! LightEntity) continue;

    Offset lightCenter = Offset(
      lightEntity.position.dx + lightEntity.width / 2,
      lightEntity.position.dy + lightEntity.height / 2,
    );

    double distance = (entityCenter - lightCenter).distance;

    if (distance > lightEntity.radius) continue;

    double intensityFactor =
        (1 - (distance / lightEntity.radius)) * lightEntity.intensity;
    finalLightColor = Color.alphaBlend(
      lightEntity.color.withAlpha((intensityFactor * 255).toInt()),
      finalLightColor,
    );
  }

  if (finalLightColor.toARGB32() == 0.0) return child;

  return ClipRRect(
    child: ColorFiltered(
      colorFilter: ColorFilter.mode(finalLightColor, BlendMode.modulate),
      child: child,
    ),
  );
}

class LightingConsumer extends StatelessWidget {
  final Entity entity;
  final List<Entity> lights;
  final Widget child;

  const LightingConsumer({
    super.key,
    required this.entity,
    required this.lights,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (lights.isEmpty) {
      return child;
    }

    // Filter lights that could potentially affect this entity
    final relevantLights = lights.where((light) {
      if (light is! LightEntity) return false;

      Offset entityCenter = Offset(
        entity.position.dx + entity.width / 2,
        entity.position.dy + entity.height / 2,
      );

      Offset lightCenter = Offset(
        light.position.dx + light.width / 2,
        light.position.dy + light.height / 2,
      );

      double distance = (entityCenter - lightCenter).distance;

      // Only listen to lights that could affect this entity (with some buffer)
      return distance <= (light).radius + 200;
    }).toList();

    if (relevantLights.isEmpty) {
      return child;
    }

    return MultiProvider(
      providers: relevantLights
          .map((light) => ChangeNotifierProvider.value(value: light))
          .toList(),
      child: Consumer<Entity>(
        builder: (context, _, __) {
          return applyLightingToEntity(
            child: child,
            entity: entity,
            lights: lights,
          );
        },
      ),
    );
  }
}
