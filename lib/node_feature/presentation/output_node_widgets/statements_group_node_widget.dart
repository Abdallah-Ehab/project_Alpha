import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';

class StatementGroupNodeWidget extends StatelessWidget {
  final StatementGroupNode node;

  const StatementGroupNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.isHighlighted
            ? Colors.orangeAccent.withAlpha(150)
            : node.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: node.isHighlighted ? Colors.deepOrange : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                "Statement Group",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: node.statements.isEmpty
                ? const Center(child: Text("No statements yet"))
                : ListView.builder(
                    itemCount: node.statements.length,
                    itemBuilder: (context, index) {
                      final statement = node.statements[index];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            statement.runtimeType.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}