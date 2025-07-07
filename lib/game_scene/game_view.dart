import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/camera_feature/presentation/camera_widget.dart';
import 'package:scratch_clone/camera_feature/presentation/editor_camera_wrapper.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/presentation/entity_renderer.dart';
import 'package:scratch_clone/game_state/game_state.dart';

class GameView extends StatefulWidget with WidgetsBindingObserver {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations( [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

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
                    .getAllEntitiesSortedByLayerNumber()
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
                                ..rotateY(entity.rotation),
                              child: EntityRenderer(entity: entity,lights: entityManager.getLights() ?? []),
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
                CustomPaint(
                  size: Size(cam.width, cam.height),
                  painter: GridPainter(
                    gridSize: 100 / cam.zoom,
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



class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({this.gridSize = 10});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    final rows = (size.height / gridSize).ceil();
    final columns = (size.width / gridSize).ceil();

    final Paint gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    for (int row = 0; row <= rows; row++) {
      double y = row * gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int col = 0; col <= columns; col++) {
      double x = col * gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
