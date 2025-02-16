import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/condition_block_target_widget.dart';


class BlockFactory extends StatelessWidget {
  BlockModel blockModel;
  BlockFactory({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return blockModel.constructBlock();
  }
}

class GenericBlockWidget extends StatelessWidget {
  BlockModel blockModel;
  GenericBlockWidget({super.key,required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 150),
            painter: BlockPainter(color: blockModel.color, widthFactor: 0.9),
          ),
          const Material(
              color: Colors.transparent, child: Text("generic block")),
        ],
      );
  }
}

class IfBlockWidget extends StatefulWidget {
  final IfStatementBlock blockModel;
  const IfBlockWidget(
      {super.key, required this.blockModel});

  @override
  State<IfBlockWidget> createState() => _IfBlockWidgetState();
}

class _IfBlockWidgetState extends State<IfBlockWidget> {
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(200, 100),
          painter: BlockPainter(
              color: widget.blockModel.color, widthFactor: 1.2, heightFactor: 0.5),
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Material(
              color: Colors.transparent,
              child: Text(
                "if",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
            ConditionBlockTargetWidget(blockModel: widget.blockModel)
          ],
        )
      ],
    );
  }
}

class PlayAnimationBlockWidget extends StatefulWidget {
  final PlayAnimationBlock blockModel;
  const PlayAnimationBlockWidget({
    super.key,
    required this.blockModel,
  });

  @override
  State<PlayAnimationBlockWidget> createState() =>
      _PlayAnimationBlockWidgetState();
}

class _PlayAnimationBlockWidgetState extends State<PlayAnimationBlockWidget> {
  String? selectedTrack;
  @override
  Widget build(BuildContext context) {
    var gameObjectManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(200, 100),
          painter: BlockPainter(
              color: widget.blockModel.color,
              widthFactor: 1,
              heightFactor: 0.5),
        ),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: Text(
                widget.blockModel.code,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 50),
            Material(
              child: SizedBox(
                height: 30,
                child: DropdownButton(
                    value: "idle",
                    focusColor: widget.blockModel.color,
                    items: gameObjectManagerProvider
                        .currentGameObject.animationTracks.keys
                        .map((track) =>
                            DropdownMenuItem(value: track, child: Text(track)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        log(value);
                      }
                      setState(() {
                        selectedTrack = value;
                        widget.blockModel.trackName = value;
                      });
                    }),
              ),
            )
          ],
        )
      ],
    );
  }
}

class BlockPainter extends CustomPainter {
  final Color color;
  final double widthFactor; // Allow blocks to have different widths
  final double heightFactor; // Allow blocks to have different heights

  const BlockPainter({
    required this.color,
    this.widthFactor = 0.6, // Default width factor
    this.heightFactor = 0.3, // Default height factor
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3); // Light grey for visibility
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Dynamic width and height based on the size provided
    double width = size.width * widthFactor;
    double height = size.height * heightFactor;

    double left = (size.width - width) / 2;
    double top = (size.height - height) / 2;

    Rect rect = Rect.fromLTWH(left, top, width, height);
    Rect oval =
        Rect.fromCircle(center: Offset(size.width / 2, top), radius: 10);
    Rect indent = Rect.fromCircle(
        center: Offset(size.width / 2, top + height), radius: 10);

    Path path = Path()
      ..addRect(rect)
      ..addOval(oval);

    Path circlePath = Path()..addOval(indent);
    Path resultPath = Path.combine(PathOperation.difference, path, circlePath);

    canvas.drawPath(resultPath, paint);
  }

  @override
  bool shouldRepaint(covariant BlockPainter oldDelegate) =>
      oldDelegate.widthFactor != widthFactor ||
      oldDelegate.heightFactor != heightFactor ||
      oldDelegate.color != color;
}