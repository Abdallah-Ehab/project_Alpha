
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/block_feature/data/block_component.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';
import 'package:scratch_clone/block_feature/presentation/draggable_block.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class IfBlockWidget extends StatelessWidget {
  final IfBlock blockModel;
  const IfBlockWidget({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    List<ConditionBlock> conditions = blockModel.conditions;
    List<BlockModel> statements = blockModel.statements;
    const double originalWidth = 150;
    const double originalHeight = 75;
    return Consumer<Entity>(
      builder: (context, entity, child) {
        final blockComponent = entity.getComponent<BlockComponent>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPaint(
              painter: BlockHeaderPainter(color: blockModel.color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: blockModel.width ,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Material(
                      color: Colors.transparent,
                      child: Text("if",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DragTarget<ConditionBlock>(
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                                color: candidateData.isNotEmpty
                                    ? Colors.red.shade300
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white30)),
                            child: Row(
                              children: conditions.isEmpty
                                  ? [
                                      const Material(
                                        color: Colors.transparent,
                                        child: Text("conditions",
                                            style: TextStyle(
                                                color: Colors.white70)),
                                      )
                                    ]
                                  : conditions
                                      .map((condition) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: DraggableBlock(
                                                blockModel: condition,
                                                removeCondition: () {
                                                  blockModel.removeCondition(
                                                      condition: condition);
                                                  log("conditionBlocks length is ${blockModel.conditions.length} and the new width is ${(blockModel.conditions.length + 1) * originalWidth}");
                                                  blockModel.setWidth((blockModel.conditions.length + 1) * originalWidth);
                                                }),
                                          ))
                                      .toList(),
                            ),
                          );
                        },
                        onAcceptWithDetails: (details) {
                          if (blockComponent != null) {
                          blockComponent.removeBlockFromWorkSpace(details.data);
                          blockModel.addConidition(details.data);
                          blockModel.setWidth((blockModel.conditions.length + 1) * originalWidth);
                        }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statements section
            CustomPaint(
              painter: BlockBodyPainter(color: blockModel.color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: blockModel.width ,
                height: blockModel.height,
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 8.0, 8.0),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DragTarget<BlockModel>(
                      builder: (context, candidateData, rejectedData) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: statements.isEmpty
                            ? [
                                const Material(
                                  color: Colors.transparent,
                                  child: Text("Drop statements here",
                                      style: TextStyle(color: Colors.white70)),
                                )
                              ]
                            : statements
                                .map((statement) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: DraggableBlock(
                                        blockModel: statement,
                                        removeStatement: () {
                                          blockModel.removeStatement(
                                              statement: statement);
                                          blockModel.setHeight((blockModel.statements.length + 1) * originalHeight);
                                        },
                                      ),
                                    ))
                                .toList(),
                      ),
                      onAcceptWithDetails: (details) {
                        if (blockComponent != null) {
                          blockComponent.removeBlockFromWorkSpace(details.data);
                          blockModel.addStatement(details.data);
                          details.data.setIsStatement(true);
                          blockModel.setHeight((blockModel.statements.length + 1) * originalHeight);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Connector tab
            CustomPaint(
              painter: BlockConnectorPainter(color: blockModel.color),
              child: SizedBox(
                width: blockModel.width,
                height: 10,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painters for Scratch-like appearance
class BlockHeaderPainter extends CustomPainter {
  final Color color;

  BlockHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(10, size.height) // Indent for the puzzle-like connector
      ..lineTo(0, size.height - 10)
      ..close();

    canvas.drawPath(path, paint);

    // Add a subtle shadow/highlight for depth
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, 0),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BlockBodyPainter extends CustomPainter {
  final Color color;

  BlockBodyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(10, 0) // Indent for the puzzle-like connector
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BlockConnectorPainter extends CustomPainter {
  final Color color;

  BlockConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    var startingPoint = size.width/2 - 20;
    final path = Path()
      ..moveTo(startingPoint, 0)
      ..lineTo(startingPoint + 10, size.height+5)
      ..lineTo(startingPoint+ 30, size.height+5)
      ..lineTo(startingPoint + 40, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Add a subtle shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(20, size.height),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
