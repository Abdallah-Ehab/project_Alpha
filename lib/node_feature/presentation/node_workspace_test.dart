import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/node_feature/presentation/arrow_painter.dart';
import 'package:scratch_clone/node_feature/presentation/node_wrapper.dart';

import 'dart:io';

// Replace with your actual imports
// import 'your_project/connection_provider.dart';
// import 'your_project/entity.dart';
// import 'your_project/node_component.dart';
// import 'your_project/node_model.dart';
// import 'your_project/node_wrapper.dart';
// import 'your_project/arrow_painter.dart';

class NodeWorkspaceTest extends StatefulWidget {
  const NodeWorkspaceTest({super.key});

  @override
  State<NodeWorkspaceTest> createState() => _NodeWorkspaceTestState();
}

class _NodeWorkspaceTestState extends State<NodeWorkspaceTest> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Node Test")),
      body: Consumer<Entity>(
        builder: (context, activeEntity, child) {
          final nodeComponent = activeEntity.getComponent<NodeComponent>();

          if (nodeComponent == null) {
            return const Center(child: Text("No NodeComponent on active entity."));
          }

          return ChangeNotifierProvider.value(
            value: nodeComponent,
            child: Consumer<NodeComponent>(
              builder: (context, value, child) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.5,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  constrained: false,
                  child: SizedBox(
                    width: 10000,
                    height: 10000,
                    child: Stack(
                      children: [
                        DragTarget<NodeModel>(
                          builder: (context, candidateData, rejectedData) {
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: GridPainter(),
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: ArrowPainter(
                                      nodes: nodeComponent.workspaceNodes,
                                      connectionProvider: connectionProvider,
                                    ),
                                  ),
                                ),
                                ...nodeComponent.workspaceNodes.map((node) {
                                  return ChangeNotifierProvider.value(
                                    value: node,
                                    child: Consumer<NodeModel>(
                                      builder: (context, value, child) {
                                        return Positioned(
                                          top: node.position.dy,
                                          left: node.position.dx,
                                          child: NodeWrapper(nodeModel: node),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                          onAcceptWithDetails: (details) {
                            final node = details.data;
                            final offset = details.offset - const Offset(25, 25);
                            final newNode = node.copyWith(position: offset);
                            nodeComponent.addNodeToWorkspace(newNode);
                          },
                        ),
                      ],
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
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({this.gridSize = 100});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withAlpha(200)
      ..strokeWidth = 1;

    for (double x = -10000; x < 10000; x += gridSize) {
      canvas.drawLine(Offset(x, -10000), Offset(x, 10000), paint);
    }
    for (double y = -10000; y < 10000; y += gridSize) {
      canvas.drawLine(Offset(-10000, y), Offset(10000, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
