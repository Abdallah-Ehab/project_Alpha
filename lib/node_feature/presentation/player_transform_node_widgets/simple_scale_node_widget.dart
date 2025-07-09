import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/simple_scale_node.dart';

class SimpleScaleNodeWidget extends StatelessWidget {
  final SetScaleNode nodeModel;

  const SimpleScaleNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    final widthController =
        TextEditingController(text: nodeModel.widthScale.toString());
    final heightController =
        TextEditingController(text: nodeModel.heightScale.toString());

    return Container(
      width: nodeModel.width,
      height: nodeModel.height,
      decoration: BoxDecoration(
        color: nodeModel.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                const Text(
                  "Scale:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widthController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "W",
                      labelStyle: TextStyle(color: Colors.white),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        nodeModel.widthScale = parsed;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: heightController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "H",
                      labelStyle: TextStyle(color: Colors.white),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        nodeModel.heightScale = parsed;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          ...nodeModel.connectionPoints.map((cp) => cp.build(context)),
        ],
      ),
    );
  }
}
