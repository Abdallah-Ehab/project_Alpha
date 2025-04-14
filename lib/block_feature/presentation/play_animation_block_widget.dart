
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class PlayAnimationBlockWidget extends StatelessWidget {
  final PlayAnimationBlock blockModel;
  const PlayAnimationBlockWidget({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CommandBlockPainter(color: blockModel.color),
      child: Container(
        width: blockModel.width,
        height: blockModel.height,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Material(
              color: Colors.transparent, 
              child: Text(
                "play animation", 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            AnimationTracksDropDownMenu(onChange: (value) {
              blockModel.setTrackName(value);
            })
          ],
        ),
      ),
    );
  }
}

// Custom painter for command blocks (e.g., Play Animation, Move)
class CommandBlockPainter extends CustomPainter {
  final Color color;
  final double notchSize = 10.0;

  CommandBlockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path()
      // Start at top-left
      ..moveTo(0, notchSize)
      // Top-left corner
      ..quadraticBezierTo(0, 0, notchSize, 0)
      // Top edge with bump
      ..lineTo(size.width - notchSize, 0)
      // Top-right corner
      ..quadraticBezierTo(size.width, 0, size.width, notchSize)
      // Right edge
      ..lineTo(size.width, size.height - notchSize)
      // Bottom-right corner
      ..quadraticBezierTo(size.width, size.height, size.width - notchSize, size.height)
      // Bottom edge with notch (for connecting blocks below)
      ..lineTo(notchSize + 15, size.height)
      // Notch
      ..lineTo(notchSize + 10, size.height - 5)
      ..lineTo(notchSize + 5, size.height)
      ..lineTo(notchSize, size.height)
      // Bottom-left corner
      ..quadraticBezierTo(0, size.height, 0, size.height - notchSize)
      // Left edge
      ..lineTo(0, notchSize + 15)
      // Notch in left side (for connecting blocks)
      ..lineTo(5, notchSize + 10)
      ..lineTo(0, notchSize + 5)
      ..close();

    // Apply a subtle shadow
    canvas.drawShadow(path, Colors.black54, 2.0, true);
    canvas.drawPath(path, paint);

    // Add a slight bevel effect with a slightly darker color
    final Paint bevelPaint = Paint()
      ..color = color.withValues(alpha:0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, bevelPaint);
  }

  @override
  bool shouldRepaint(CommandBlockPainter oldDelegate) => color != oldDelegate.color;
}



class AnimationTracksDropDownMenu extends StatelessWidget {
  final ValueChanged<dynamic>? onChange;
  const AnimationTracksDropDownMenu({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(
      builder: (context, activeEntity, child) {
        var animationComponent = activeEntity.getComponent<AnimationControllerComponent>();
        if (animationComponent == null) {
          return const Material(
            color: Colors.transparent,
            child: Text(
              "no animation available",
              style: TextStyle(color: Colors.white70),
            ),
          );
        } else {
          return ChangeNotifierProvider.value(
            value: animationComponent,
            child: Consumer<AnimationControllerComponent>(
              builder: (context, animationComponent, child) {
                return Material(
                  color: Colors.transparent,
                  child: DropdownButton(
                    dropdownColor: Colors.purple.shade800,
                    style: const TextStyle(color: Colors.white),
                    underline: Container(height: 1, color: Colors.white30),
                    hint: const Text(
                      "Select animation",
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: animationComponent.animationTracks.keys
                      .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                      .toList(),
                    onChanged: onChange,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}