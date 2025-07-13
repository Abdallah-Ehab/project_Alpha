import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/data/light_entity.dart';
import 'package:scratch_clone/entity/presentation/entity_renderer.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_widget.dart';



class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entityManager = context.watch<EntityManager>();
    final camera = entityManager.getActiveCamera();
    final gameState = context.watch<GameState>();

    return ChangeNotifierProvider.value(
      value: camera,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize =
              Size(constraints.maxWidth, constraints.maxHeight);

          // Update camera viewport size
          WidgetsBinding.instance.addPostFrameCallback((_) {
            camera.setViewportSize(viewportSize);
          });

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) {
              _isPanning = false;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 1) {
                // Single finger - pan
                if (!_isPanning) {
                  _isPanning = true;
                }
                camera.pan(-details.focalPointDelta / camera.zoom);
              } else if (details.pointerCount == 2) {
                // Two fingers - zoom
                camera.zoomAt(details.localFocalPoint, details.scale);
              }
            },
            child: Consumer<CameraEntity>(
              builder: (context, camera, child) {
                return Container(
                  width: viewportSize.width,
                  height: viewportSize.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    color: Colors.transparent,
                  ),
                  child: ClipRect(
                    child: DragTarget<Entity>(
                      onAcceptWithDetails: (details) {
                        entityManager.spawnPrefabAtPosition(
                            details.data.name, details.offset);
                      },
                      builder: (context, candidateData, rejectedData) => Stack(
                        children: [
                          // Grid background
                          CustomPaint(
                            size: viewportSize,
                            painter: GameGridPainter(
                              camera: camera,
                              viewportSize: viewportSize,
                            ),
                          ),
                          // Entities
                          ...entityManager
                              .getAllEntitiesSortedByLayerNumber()
                              .where(
                                  (entity) => _isEntityVisible(entity, camera))
                              .map((entity) => GameEntityRenderer(
                                    entity: entity,
                                    camera: camera,
                                    viewportSize: viewportSize,
                                    lights: entityManager.getLights() ?? [],
                                    gameState: gameState,
                                    entityManager: entityManager,
                                    onPanStart: () => _isPanning = false,
                                  )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  bool _isEntityVisible(Entity entity, CameraEntity camera) {
    final entityRect = Rect.fromLTWH(
      entity.position.dx,
      entity.position.dy,
      entity.width + 200, // Add some padding for optimization
      entity.height + 200,
    );
    return camera.isRectVisible(entityRect);
  }
}

class GameEntityRenderer extends StatefulWidget {
  final Entity entity;
  final CameraEntity camera;
  final Size viewportSize;
  final List<Entity> lights;
  final GameState gameState;
  final EntityManager entityManager;
  final VoidCallback? onPanStart;

  const GameEntityRenderer({
    super.key,
    required this.entity,
    required this.camera,
    required this.viewportSize,
    required this.lights,
    required this.gameState,
    required this.entityManager,
    this.onPanStart,
  });

  @override
  State<GameEntityRenderer> createState() => _GameEntityRendererState();
}

class _GameEntityRendererState extends State<GameEntityRenderer> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.entity,
      child: Consumer2<Entity, CameraEntity>(
        builder: (context, entity, camera, child) {
          final screenPosition = camera.worldToScreen(entity.position);
          final collider = entity.getComponent<ColliderComponent>();
          final Offset colliderScreenPosition;
          if (collider != null) {
            colliderScreenPosition = camera.worldToScreen(collider.position);
          }
          return Positioned(
            left: screenPosition.dx,
            top: screenPosition.dy,
            child: Transform.scale(
              scale: camera.zoom,
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  if (widget.gameState.isPlaying) {
                    entity.setVariableXToValueY('ontap', true);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      entity.setVariableXToValueY('ontap', false);
                    });
                  } else {
                    widget.entityManager.activeEntity = entity;
                  }
                },
                onPanStart: (details) {
                  if (!widget.gameState.isPlaying) {
                    _isDragging = true;
                    widget.onPanStart?.call();
                  }
                },
                onPanUpdate: (details) {
                  if (!widget.gameState.isPlaying && _isDragging) {
                    // Convert screen delta to world delta
                    final worldDelta = details.delta / camera.zoom;
                    final newPosition = entity.position + worldDelta;

                    entity.teleport(dx: newPosition.dx, dy: newPosition.dy);
                  }
                },
                onPanEnd: (details) {
                  _isDragging = false;
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(entity.rotation)
                    ..scale(
                      entity.isFlippedX ? -1.0 : 1.0, // Horizontal flip
                      entity.isFlippedY ? -1.0 : 1.0, // Vertical flip
                    ),
                  child: EntityContentRenderer(
                    entity: entity,
                    lights: widget.lights,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EntityContentRenderer extends StatelessWidget {
  final Entity entity;
  final List<Entity> lights;

  const EntityContentRenderer({
    super.key,
    required this.entity,
    required this.lights,
  });

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
              painter: EntityPainter(keyFrame: keyFrame,trackPosition :animationController.currentAnimationTrack.position,),
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
              gradient: RadialGradient(
                  colors: [(entity as LightEntity).color, Colors.transparent]),
              shape: BoxShape.circle),
          child: Center(child: Icon(Icons.lightbulb)),
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
        // Main entity content - positioned at origin since we handle positioning in parent
        LightingConsumer(
          entity: entity,
          lights: lights,
          child: animationWidget,
        ),
        // Collider component - relative positioning
        if (colliderComponent != null)
          ChangeNotifierProvider.value(
            value: colliderComponent,
            child: Consumer<ColliderComponent>(
              builder: (context, value, child) {
                return Positioned(
                  top: value.position.dy,
                  left: value.position.dx,
                  child: ColliderWidget(
                    width: value.width,
                    height: value.height,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class GameGridPainter extends CustomPainter {
  final double gridSize;
  final CameraEntity camera;
  final Size viewportSize;

  GameGridPainter({
    this.gridSize = 100,
    required this.camera,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final paint = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 1.0;

    // Calculate visible world bounds
    final worldBounds = camera.getVisibleWorldBounds();

    // Calculate grid start positions
    final startX = (worldBounds.left / gridSize).floor() * gridSize;
    final startY = (worldBounds.top / gridSize).floor() * gridSize;
    final endX = (worldBounds.right / gridSize).ceil() * gridSize;
    final endY = (worldBounds.bottom / gridSize).ceil() * gridSize;

    // Draw vertical lines
    for (double x = startX; x <= endX; x += gridSize) {
      final screenX = (x - camera.position.dx) * camera.zoom;
      if (screenX >= 0 && screenX <= size.width) {
        canvas.drawLine(
          Offset(screenX, 0),
          Offset(screenX, size.height),
          paint,
        );
      }
    }

    // Draw horizontal lines
    for (double y = startY; y <= endY; y += gridSize) {
      final screenY = (y - camera.position.dy) * camera.zoom;
      if (screenY >= 0 && screenY <= size.height) {
        canvas.drawLine(
          Offset(0, screenY),
          Offset(size.width, screenY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GameGridPainter oldDelegate) {
    return camera != oldDelegate.camera ||
        viewportSize != oldDelegate.viewportSize;
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({this.gridSize = 10});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);
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
