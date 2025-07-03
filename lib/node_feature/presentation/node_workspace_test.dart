import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/node_feature/presentation/node_deck.dart';

class NodeWorkspaceCamera extends ChangeNotifier {
  Offset _position = Offset.zero;
  double _zoom = 1.0;

  Offset get position => _position;
  double get zoom => _zoom;

  void pan(Offset delta) {
    _position += delta;
    notifyListeners();
  }

  void setZoom(double newZoom) {
    _zoom = newZoom.clamp(0.1, 5.0);
    notifyListeners();
  }

  void zoomAt(Offset point, double delta) {
    final newZoom = (_zoom * delta).clamp(0.1, 5.0);
    final zoomFactor = newZoom / _zoom;
    _position = point - (point - _position) * zoomFactor;
    _zoom = newZoom;
    notifyListeners();
  }

  // Convert screen coordinates to world coordinates
  Offset screenToWorld(Offset screenPoint, Size viewportSize) {
    return (screenPoint / _zoom) + _position;
  }

  // Convert world coordinates to screen coordinates
  Offset worldToScreen(Offset worldPoint, Size viewportSize) {
    return (worldPoint - _position) * _zoom;
  }

  // Check if a world rectangle is visible in the viewport
  bool isRectVisible(Rect worldRect, Size viewportSize) {
    final viewportRect = Rect.fromLTWH(
      _position.dx,
      _position.dy,
      viewportSize.width / _zoom,
      viewportSize.height / _zoom,
    );
    return viewportRect.overlaps(worldRect);
  }
}

// Enhanced Node Workspace
class NodeWorkspaceTest extends StatefulWidget {
  const NodeWorkspaceTest({super.key});

  @override
  State<NodeWorkspaceTest> createState() => _NodeWorkspaceTestState();
}

class _NodeWorkspaceTestState extends State<NodeWorkspaceTest> {
  late NodeWorkspaceCamera _camera;
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    _camera = NodeWorkspaceCamera();
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final entityManager = context.read<EntityManager>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: NodeDeck(),
      body: ChangeNotifierProvider.value(
        value: entityManager.activeEntity,
        child: Consumer<Entity>(
          builder: (context, activeEntity, child) {
            final nodeComponent = activeEntity.getComponent<NodeComponent>();

            if (nodeComponent == null) {
              return const Center(
                  child: Text("No NodeComponent on active entity."));
            }

            return ChangeNotifierProvider.value(
              value: nodeComponent,
              child: ChangeNotifierProvider.value(
                value: _camera,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportSize =
                        Size(constraints.maxWidth, constraints.maxHeight);

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
                          _camera.pan(-details.focalPointDelta / _camera.zoom);
                        } else if (details.pointerCount == 2) {
                          // Two fingers - zoom
                          _camera.zoomAt(
                              details.localFocalPoint, details.scale);
                        }
                      },
                      child: Consumer2<NodeComponent, NodeWorkspaceCamera>(
                        builder: (context, nodeComponent, camera, child) {
                          return DragTarget<NodeModel>(
                            onAcceptWithDetails: (details){
                              nodeComponent.addNodeToWorkspace(details.data.copyWith(position: camera.screenToWorld(details.offset, viewportSize)));
                            },
                            builder: (context, candidateData, rejectedData) =>  ClipRect(
                              child: CustomPaint(
                                size: viewportSize,
                                painter: InfiniteGridPainter(
                                  camera: camera,
                                  viewportSize: viewportSize,
                                ),
                                child: Stack(
                                  children: [
                                    // Connection lines
                                    CustomPaint(
                                      size: viewportSize,
                                      painter: InfiniteArrowPainter(
                                        nodes: nodeComponent.workspaceNodes,
                                        connectionProvider: connectionProvider,
                                        camera: camera,
                                        viewportSize: viewportSize,
                                      ),
                                    ),
                                    // Nodes
                                    ...nodeComponent.workspaceNodes
                                        .where((node) => _camera.isRectVisible(
                                              Rect.fromLTWH(
                                                node.position.dx,
                                                node.position.dy,
                                                node.width,
                                                node.height,
                                              ),
                                              viewportSize,
                                            ))
                                        .map((node) {
                                      return InfiniteNodeRenderer(
                                        key: ValueKey(node.id),
                                        nodeModel: node,
                                        camera: _camera,
                                        viewportSize: viewportSize,
                                        onDragStart: () => _isPanning = false,
                                      );
                                    }),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

// Separate widget to handle node rendering with proper rebuilding
class InfiniteNodeRenderer extends StatelessWidget {
  final NodeModel nodeModel;
  final NodeWorkspaceCamera camera;
  final Size viewportSize;
  final VoidCallback? onDragStart;

  const InfiniteNodeRenderer({
    super.key,
    required this.nodeModel,
    required this.camera,
    required this.viewportSize,
    this.onDragStart,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: nodeModel,
      child: Consumer2<NodeModel, NodeWorkspaceCamera>(
        builder: (context, node, cam, child) {
          final screenPosition = cam.worldToScreen(
            node.position,
            viewportSize,
          );

          return Positioned(
            left: screenPosition.dx,
            top: screenPosition.dy,
            child: Transform.scale(
              scale: cam.zoom,
              alignment: Alignment.topLeft,
              child: InfiniteNodeWrapper(
                nodeModel: node,
                camera: cam,
                viewportSize: viewportSize,
                onDragStart: onDragStart,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Node Wrapper with infinite workspace support
class InfiniteNodeWrapper extends StatefulWidget {
  final NodeModel nodeModel;
  final NodeWorkspaceCamera camera;
  final Size viewportSize;
  final VoidCallback? onDragStart;

  const InfiniteNodeWrapper({
    super.key,
    required this.nodeModel,
    required this.camera,
    required this.viewportSize,
    this.onDragStart,
  });

  @override
  State<InfiniteNodeWrapper> createState() => _InfiniteNodeWrapperState();
}

class _InfiniteNodeWrapperState extends State<InfiniteNodeWrapper> {
  bool _isDragging = false;
  Offset? _dragStartPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        _dragStartPosition = widget.nodeModel.position;
        widget.onDragStart?.call();
      },
      onPanUpdate: (details) {
        if (!_isDragging) return;

        // Convert screen delta to world delta
        final worldDelta = details.delta / widget.camera.zoom;

        final entityManager =
            Provider.of<EntityManager>(context, listen: false);
        final activeEntity = entityManager.activeEntity;
        final nodeComponent = activeEntity.getComponent<NodeComponent>();

        if (nodeComponent == null) return;

        // Update node position in world space
        final newPosition = widget.nodeModel.position + worldDelta;
        widget.nodeModel.updatePosition(newPosition);

        // Handle statement group overlapping
        _handleStatementGroupOverlapping(nodeComponent);
      },
      onPanEnd: (details) {
        if (!_isDragging) return;
        _isDragging = false;

        final entityManager =
            Provider.of<EntityManager>(context, listen: false);
        final activeEntity = entityManager.activeEntity;
        final nodeComponent = activeEntity.getComponent<NodeComponent>();

        if (nodeComponent == null) return;

        // Handle statement group dropping
        _handleStatementGroupDropping(nodeComponent);
      },
      child: widget.nodeModel.buildNode(),
    );
  }

  void _handleStatementGroupOverlapping(NodeComponent nodeComponent) {
    // Your existing overlapping logic - adapted for world coordinates
    for (var node in nodeComponent.workspaceNodes) {
      if (node is! StatementGroupNode) continue;

      final groupRect = Rect.fromLTWH(
        node.position.dx,
        node.position.dy,
        node.width,
        node.height,
      );

      final draggedRect = Rect.fromLTWH(
        widget.nodeModel.position.dx,
        widget.nodeModel.position.dy,
        widget.nodeModel.width,
        widget.nodeModel.height,
      );

      if (groupRect.overlaps(draggedRect.inflate(20)) &&
          widget.nodeModel is! StatementGroupNode) {
        node.highlightNode(true);
        break;
      } else {
        node.highlightNode(false);
      }
    }
  }

  void _handleStatementGroupDropping(NodeComponent nodeComponent) {
    // Your existing dropping logic
    for (var node in nodeComponent.workspaceNodes) {
      if (node is! StatementGroupNode) continue;

      final groupRect = Rect.fromLTWH(
        node.position.dx,
        node.position.dy,
        node.width,
        node.height,
      );

      final draggedRect = Rect.fromLTWH(
        widget.nodeModel.position.dx,
        widget.nodeModel.position.dy,
        widget.nodeModel.width,
        widget.nodeModel.height,
      );

      if (groupRect.overlaps(draggedRect.inflate(20)) &&
          widget.nodeModel is! StatementGroupNode) {
        final alreadyExists =
            node.statements.any((s) => s.id == widget.nodeModel.id);
        if (!alreadyExists && !widget.nodeModel.isStatement) {
          node.addStatement(widget.nodeModel);
          widget.nodeModel.isStatement = true;
          node.highlightNode(false);
          nodeComponent.removeNodeFromWorkspace(widget.nodeModel);
        }
        break;
      }
    }
  }
}

class InfiniteGridPainter extends CustomPainter {
  final double gridSize;
  final NodeWorkspaceCamera camera;
  final Size viewportSize;

  InfiniteGridPainter({
    this.gridSize = 100,
    required this.camera,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 1.0;

    // Calculate visible world bounds
    final worldBounds = Rect.fromLTWH(
      camera.position.dx,
      camera.position.dy,
      viewportSize.width / camera.zoom,
      viewportSize.height / camera.zoom,
    );

    // Calculate grid start positions
    final startX = (worldBounds.left / gridSize).floor() * gridSize;
    final startY = (worldBounds.top / gridSize).floor() * gridSize;
    final endX = (worldBounds.right / gridSize).ceil() * gridSize;
    final endY = (worldBounds.bottom / gridSize).ceil() * gridSize;

    // Draw vertical lines
    for (double x = startX; x <= endX; x += gridSize) {
      final screenX = (x - camera.position.dx) * camera.zoom;
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = startY; y <= endY; y += gridSize) {
      final screenY = (y - camera.position.dy) * camera.zoom;
      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteGridPainter oldDelegate) {
    return camera != oldDelegate.camera ||
        viewportSize != oldDelegate.viewportSize;
  }
}

class InfiniteArrowPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final ConnectionProvider connectionProvider;
  final NodeWorkspaceCamera camera;
  final Size viewportSize;

  InfiniteArrowPainter({
    required this.nodes,
    required this.connectionProvider,
    required this.camera,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw temporary connection line if exists
    if (connectionProvider.fromPoint != null &&
        connectionProvider.currentPosition != null) {
      final ownernode = _findOwnerOfPoint(connectionProvider.fromPoint!, nodes);
      final startPosition = ownernode!.position +
          connectionProvider.fromPoint!.computeOffset(ownernode);
      final startPoint = camera.worldToScreen(startPosition, viewportSize);
      final endPoint = camera.worldToScreen(
          connectionProvider.currentPosition!, viewportSize);
      paint.color = Colors.grey;
      _drawArrow(canvas, paint, startPoint, endPoint, dashed: true);
    }

    for (final node in nodes) {
      if (node.child != null) {
        final child = node.child!;
        final bottomPoint = node.connectionPoints
            .firstWhereOrNull((p) => p is ConnectConnectionPoint && !p.isTop);
        final topPoint = child.connectionPoints
            .firstWhereOrNull((p) => p is ConnectConnectionPoint && p.isTop);

        if (bottomPoint != null && topPoint != null) {
          final start = node.position + bottomPoint.computeOffset(node);
          final end = child.position + topPoint.computeOffset(child);
          final startPoint = camera.worldToScreen(start, viewportSize);
          final endPoint = camera.worldToScreen(end, viewportSize);

          paint.color = Colors.blueGrey;
          _drawArrow(canvas, paint, startPoint, endPoint, dashed: false);
        }
      }

      if (node is HasOutput && node.output != null) {
        final outputPoint = node.connectionPoints
            .firstWhereOrNull((p) => p is OutputConnectionPoint);
        final inputPoint = node.output!.connectionPoints
            .firstWhereOrNull((p) => p is InputConnectionPoint);

        if (outputPoint != null && inputPoint != null) {
          final start = camera.worldToScreen(node.position, viewportSize) +
              outputPoint.computeOffset(node);
          final end =
              camera.worldToScreen(node.output!.position, viewportSize) +
                  inputPoint.computeOffset(node.output!);
          paint.color = Colors.red;
          _drawArrow(canvas, paint, start, end, dashed: false);
        }
      }

      if (node is OutputNodeWithValue && node.sourceNode != null) {
        final sourceNode = node.sourceNode!;
        final sourcePoints =
            sourceNode.connectionPoints.whereType<ValueConnectionPoint>();
        final targetPoints =
            node.connectionPoints.whereType<ValueConnectionPoint>();

        for (final targetCp in targetPoints) {
          if (!targetCp.isConnected) continue;

          final int? targetSourceIndex = targetCp.sourceIndex;
          if (targetSourceIndex == null) continue;

          // Find the ValueConnectionPoint in the source node that matches the sourceIndex
          final sourceCp = sourcePoints
              .firstWhereOrNull((cp) => cp.valueIndex == targetSourceIndex);

          if (sourceCp != null) {
            final start =
                camera.worldToScreen(sourceNode.position + sourceCp.computeOffset(sourceNode),viewportSize);
            final end = camera.worldToScreen(node.position + targetCp.computeOffset(node),viewportSize);
            paint.color = Colors.orange;
            _drawArrow(canvas, paint, start, end,
                dashed: false); // Your custom arrow-drawing logic
          }
        }
      }
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end,
      {bool dashed = false}) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final cp1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final cp2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // Draw arrowhead
    final arrowSize = 8;
    final angle = atan2(end.dy - cp2.dy, end.dx - cp2.dx);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6))
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6));
    canvas.drawPath(arrowPath, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6;
    const dashSpace = 4;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  NodeModel? _findOwnerOfPoint(
      ConnectionPointModel point, List<NodeModel> nodes) {
    for (var node in nodes) {
      if (node.connectionPoints.contains(point)) {
        return node;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant InfiniteArrowPainter oldDelegate) {
    return true;
  }
}
