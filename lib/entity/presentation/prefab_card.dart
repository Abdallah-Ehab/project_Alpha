import 'package:flutter/material.dart';

class PrefabCard extends StatelessWidget {
  final String prefabName;

  const PrefabCard({super.key, required this.prefabName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prefabName,
            style: const TextStyle(color: Colors.white),
          ),
          const Icon(Icons.drag_indicator, color: Colors.white),
        ],
      ),
    );
  }
}
