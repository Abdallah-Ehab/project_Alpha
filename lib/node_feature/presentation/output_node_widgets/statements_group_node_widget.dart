import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/presentation/node_wrapper.dart';

class StatementGroupNodeWidget extends StatefulWidget {
  final StatementGroupNode node;

  const StatementGroupNodeWidget({super.key, required this.node});

  @override
  State<StatementGroupNodeWidget> createState() => _StatementGroupNodeWidgetState();
}

class _StatementGroupNodeWidgetState extends State<StatementGroupNodeWidget> {
  @override
  Widget build(BuildContext context) {
    // Base height + per-statement height
    double calculatedHeight = 100 + widget.node.statements.length * 90;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      width: widget.node.width,
      height: calculatedHeight.clamp(120.0, 600.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.node.isHighlighted
                    ? Colors.orangeAccent.withAlpha(150)
                    : widget.node.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.node.isHighlighted ? Colors.deepOrange : Colors.black,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "Statement Group",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Divider(),
                  if (widget.node.statements.isEmpty)
                    const Center(child: Text("No statements yet")),
                  ...widget.node.statements.map((statement) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: NodeWrapper(nodeModel: statement),
                      )),
                ],
              ),
            ),
          ),

          // Connection points (top/bottom)
          for (final cp in widget.node.connectionPoints)
            cp.build(context),
        ],
      ),
    );
  }
}
