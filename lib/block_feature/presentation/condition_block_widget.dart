import 'package:flutter/material.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';

class ConditionBlockWidget extends StatelessWidget {
  final ConditionBlock blockModel;
  const ConditionBlockWidget({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexagonalBlockPainter(color: blockModel.color),
      child: Container(
        width: blockModel.width,
        height: blockModel.height,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First operand (left side) text field
            SizedBox(
              width: 30,
              height: 30,
              child: Material(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    hintText: "x",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  controller: TextEditingController(
                      text: blockModel.firstOperand.toString() == "null" ? "x" : blockModel.firstOperand.toString()),
                  onChanged: (value) {
                    blockModel.setFirstOperandAsString(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Operator selector (keep as dropdown)
            SizedBox(
              width: 50,
              child: Material(
                color: Colors.transparent,
                child: DropdownButton<String>(
                  dropdownColor: blockModel.color.withValues(alpha: 0.9),
                  style: const TextStyle(color: Colors.white),
                  value: blockModel.comparisonOperator ?? "==",
                  underline: Container(height: 1, color: Colors.white30),
                  items: const [
                    DropdownMenuItem(value: ">", child: Text(">")),
                    DropdownMenuItem(value: "<", child: Text("<")),
                    DropdownMenuItem(value: "==", child: Text("==")),
                    DropdownMenuItem(value: ">=", child: Text(">=")),
                    DropdownMenuItem(value: "<=", child: Text("<=")),
                  ],
                  onChanged: 
                  (value) {
                    if (value != null) {
                      blockModel.setComparisonOperator(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            SizedBox(
              width: 30,
              height: 30,
              child: Material(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  controller: TextEditingController(
                      text: blockModel.secondOperand ?? "0"),
                  onChanged: (value) {
                    blockModel.setSecondOperandAsString(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for condition blocks (hexagonal shape)
class HexagonalBlockPainter extends CustomPainter {
  final Color color;
  final double cornerRadius = 6.0;

  HexagonalBlockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create a hexagonal/diamond shape for condition blocks
    final Path path = Path()
      // Start at left point
      ..moveTo(cornerRadius, size.height / 2)
      // Top-left edge
      ..lineTo(cornerRadius + 10, cornerRadius)
      // Top edge
      ..lineTo(size.width - cornerRadius - 10, cornerRadius)
      // Top-right edge
      ..lineTo(size.width - cornerRadius, size.height / 2)
      // Bottom-right edge
      ..lineTo(size.width - cornerRadius - 10, size.height - cornerRadius)
      // Bottom edge
      ..lineTo(cornerRadius + 10, size.height - cornerRadius)
      // Close path
      ..close();

    // Apply a subtle shadow
    canvas.drawShadow(path, Colors.black54, 2.0, true);
    canvas.drawPath(path, paint);

    // Add a slight bevel effect with a slightly darker color
    final Paint bevelPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, bevelPaint);
  }

  @override
  bool shouldRepaint(HexagonalBlockPainter oldDelegate) =>
      color != oldDelegate.color;
}
