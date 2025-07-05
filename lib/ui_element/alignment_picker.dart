import 'package:flutter/material.dart';

class AlignmentPicker extends StatelessWidget {
  final Alignment selected;
  final ValueChanged<Alignment> onSelected;

  const AlignmentPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _alignments = [
    [Alignment.topLeft, Alignment.topCenter, Alignment.topRight],
    [Alignment.centerLeft, Alignment.center, Alignment.centerRight],
    [Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (col) {
            final alignment = _alignments[row][col];
            final isSelected = alignment == selected;

            return GestureDetector(
              onTap: () => onSelected(alignment),
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.grey[400],
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
