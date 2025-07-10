import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/time_related_nodes/wait_for_node.dart';

class WaitForNodeWidget extends StatelessWidget {
  final WaitForNode node;

  const WaitForNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: node.waitSeconds.toString());

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
              children: [
                const Text(
                  "Wait For",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Seconds: "),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) node.setWaitSeconds(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
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
