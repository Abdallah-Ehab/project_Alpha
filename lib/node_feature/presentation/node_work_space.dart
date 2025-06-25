import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/node_wrapper.dart';

class NodeWorkSpace extends StatelessWidget {
  const NodeWorkSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(builder: (context, entityManager, _) {
      final activeEntity = entityManager.activeEntity;

      return ChangeNotifierProvider.value(
        value: activeEntity,
        child: Consumer<Entity>(
          builder: (context, activeEntity, _) {
            final nodeComponent = activeEntity.getComponent<NodeComponent>();

            if (nodeComponent == null) {
              return const Center(child: Text('No node component attached'));
            }

            return ChangeNotifierProvider.value(
              value: nodeComponent,
              child: Consumer<NodeComponent>(
                builder: (context, nodeComponent, _) {
                  return DragTarget<NodeModel>(
                    builder: (context, accepted, refused) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade100,
                        child: InteractiveViewer(
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.1,
                          maxScale: 5.0,
                          child: Container(
                            width: 2000,
                            height: 2000,
                            color: Colors.grey.shade100,
                            child: Stack(
                              children: nodeComponent.workspaceNodes.map((node) {
                                return ChangeNotifierProvider.value(
                                  value: node,
                                  child: Consumer<NodeModel>(
                                    builder: (context, node, _) {
                                      return Positioned(
                                        top: node.position.dy,
                                        left: node.position.dx,
                                        child: NodeWrapper(nodeModel: node),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                    onAcceptWithDetails: (details) {
                      final node = details.data;
                      final nodeComponent =
                          activeEntity.getComponent<NodeComponent>();
                      if (nodeComponent != null) {
                        final existingNode = nodeComponent.workspaceNodes
                            .firstWhereOrNull((n) => n.id == node.id);
                        if (existingNode != null) {
                          existingNode.updatePosition(details.offset);
                        } else {
                          final newNode = node.copyWith(position: details.offset);
                          nodeComponent.addNodeToWorkspace(newNode);
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

