import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';

class MathNodeWidget extends StatelessWidget {
  final InputNodeWithValue node;
  final String label;

  const MathNodeWidget({super.key, required this.node, required this.label});

  @override
  Widget build(BuildContext context) {
    final aCp = node.connectionPoints[1] as ValueConnectionPoint;
    final bCp = node.connectionPoints[2] as ValueConnectionPoint;

    final aController = TextEditingController(text: (node as dynamic).a.toString());
    final bController = TextEditingController(text: (node as dynamic).b.toString());

    return SizedBox(
      width: node.width,
      height: node.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: node.color,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(label, style: const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (aCp.sourcePoint == null)
                        Expanded(
                          child: TextField(
                            controller: aController,
                            onSubmitted: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) (node as dynamic).setA(parsed);
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(isDense: true, labelText: 'A'),
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (bCp.sourcePoint == null)
                        Expanded(
                          child: TextField(
                            controller: bController,
                            onSubmitted: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) (node as dynamic).setB(parsed);
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(isDense: true, labelText: 'B'),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
          for (final cp in node.connectionPoints) cp.build(context),
        ],
      ),
    );
  }
}
