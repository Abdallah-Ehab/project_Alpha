import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/camera_feature/presentation/camera_widget.dart';
import 'package:scratch_clone/camera_feature/presentation/editor_camera_wrapper.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/presentation/entity_renderer.dart';
import 'package:scratch_clone/game_state/game_state.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.watch<EntityManager>();
    final camera = entityManager.activeCamera;
    final gameState = context.watch<GameState>();
    return ChangeNotifierProvider.value(
      value: camera,
      child: Consumer<CameraEntity>(
        builder: (context, cam, _) {
          final scene = Transform(
            transform: Matrix4.identity()
              ..translate(-cam.position.dx, -cam.position.dy)
              ..scale(cam.zoom),
            child: Stack(
              children: [
                // Render non-camera entities
                ...entityManager
                    .getSortedEntityByLayerNumber(EntityType.actors)
                    .where((e) => isInCameraView(cam, e))
                    .map(
                      (e) => ChangeNotifierProvider.value(
                        value: e,
                        child: Consumer<Entity>(
                          builder: (context, entity, _) => GestureDetector(
                            onTap:() {
                              if(gameState.isPlaying){
                                entity.setOnTapVariable(true);
                              }else{
                                entityManager.activeEntity = entity;
                              }
                            },
                            child: Transform(
                              transform: Matrix4.identity()
                                ..translate(
                                    entity.position.dx, entity.position.dy)
                                ..scale(entity.widthScale, entity.heigthScale)
                                ..rotateY(entity.rotation),
                              child: EntityRenderer(entity: entity),
                            ),
                          ),
                        ),
                      ),
                    ),
                CameraWidget()
              ],
            ),
          );

          return Container(
            width: cam.width,
            height: cam.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                // Grid background moves with camera
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      scale:0.01,
                      repeat: ImageRepeat.repeat,
                      
                      image: AssetImage("assets/grid_image.jpg"),
                    ),
                  ),
                ),
                // Scene on top
                cam.isEditorCamera
                    ? EditorCameraWrapper(camera: cam, child: scene)
                    : scene,
              ],
            ),
          );
        },
      ),
    );
  }

  bool isInCameraView(CameraEntity camera, Entity entity) {
    final entityRect = Rect.fromLTWH(
      entity.position.dx,
      entity.position.dy,
      entity.width + 200,
      entity.height + 200,
    );
    final cameraRect = Rect.fromLTWH(
      camera.position.dx,
      camera.position.dy,
      camera.width / camera.zoom,
      camera.height / camera.zoom,
    );
    return cameraRect.overlaps(entityRect);
  }
}
