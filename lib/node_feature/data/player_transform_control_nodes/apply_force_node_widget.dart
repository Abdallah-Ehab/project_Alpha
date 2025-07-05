import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/apply_force_node.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';


class ApplyForceNodeWidget extends StatelessWidget {
  final ApplyForceNode node;

  const ApplyForceNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final entity = context.read<EntityManager>().activeEntity;
    final hasRigidBody = entity?.getComponent<RigidBodyComponent>() != null;

    final fxController = TextEditingController(text: node.fx.toString());
    final fyController = TextEditingController(text: node.fy.toString());

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Node UI
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Apply Force",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Fx: "),
                    Expanded(
                      child: TextField(
                        controller: fxController,
                        onSubmitted: hasRigidBody
                            ? (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) node.setFx(parsed);
                              }
                            : null,
                        enabled: hasRigidBody,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text("Fy: "),
                    Expanded(
                      child: TextField(
                        controller: fyController,
                        onSubmitted: hasRigidBody
                            ? (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) node.setFy(parsed);
                              }
                            : null,
                        enabled: hasRigidBody,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
                ),
                if (!hasRigidBody)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Text(
                      "RigidBody not found",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.redAccent,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Connection Points
          for (var point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
