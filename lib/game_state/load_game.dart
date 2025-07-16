import 'dart:convert';
import 'dart:io';

import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

Future<void> loadGame(EntityManager entityManager, String path) async {
  final file = File(path);
  if (!await file.exists()) return;

  final jsonStr = await file.readAsString();
  final jsonMap = jsonDecode(jsonStr);

  // Reconstruct entities and components
  entityManager.fromJson(jsonMap);

  // Now reconstruct all KeyFrame.ui.Image fields from base64
  for (final entity in entityManager.allEntities) {
    final animComponent = entity.getComponent<AnimationControllerComponent>();
    if (animComponent == null) continue;

    for (final track in animComponent.animationTracks.values) {
      for (final frame in track.frames) {
        if (frame.imageBase64 != null) {
          try {
            frame.image = await base64ToImage(frame.imageBase64!);
          } catch (e) {
            print("Failed to decode image: $e");
          }
        }
      }
    }
  }


  for (final prefab in entityManager.prefabs.values) {
    final animComponent = prefab.getComponent<AnimationControllerComponent>();
    if (animComponent == null) continue;

    for (final track in animComponent.animationTracks.values) {
      for (final frame in track.frames) {
        if (frame.imageBase64 != null) {
          try {
            frame.image = await base64ToImage(frame.imageBase64!);
          } catch (e) {
            print("Failed to decode image: $e");
          }
        }
      }
    }
  }
}
