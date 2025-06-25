import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';

import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/node_feature/presentation/arrow_painter.dart';
import 'package:scratch_clone/node_feature/presentation/node_wrapper.dart';

class NodeWorkspaceTest extends StatelessWidget {
  const NodeWorkspaceTest({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Node Test")),
      body: Consumer<Entity>(
        builder: (context, activeEntity, child) {
          final nodeComponent = activeEntity.getComponent<NodeComponent>();

          if (nodeComponent == null) {
            return const Center(
                child: Text("No NodeComponent on active entity."));
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
                    width: 5000,
                    height: 5000,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: ArrowPainter(
                                nodes: nodeComponent.workspaceNodes,
                                connectionProvider: connectionProvider,
                              ),
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
