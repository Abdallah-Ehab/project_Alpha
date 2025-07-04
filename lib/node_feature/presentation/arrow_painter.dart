import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';

class ArrowPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final ConnectionProvider connectionProvider;

  ArrowPainter({
    required this.nodes,
    required this.connectionProvider,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      // 1. Draw connect ➝ connect (parent ➝ child)
      if (node.child != null) {
        final child = node.child!;
        final bottomPoint = node.connectionPoints
            .firstWhereOrNull((p) => p is ConnectConnectionPoint && !p.isTop);
        final topPoint = child.connectionPoints
            .firstWhereOrNull((p) => p is ConnectConnectionPoint && p.isTop);

        if (bottomPoint != null && topPoint != null) {
          final start = node.position + bottomPoint.computeOffset();
          final end = child.position + topPoint.computeOffset();
      
          paint.color = Colors.blueGrey;
          _drawArrow(canvas, paint, start, end, dashed: false);
        }
      }

      // 2. Draw output ➝ input
      if (node is HasOutput && node.output != null) {
        final outputPoint = node.connectionPoints
            .firstWhereOrNull((p) => p is OutputConnectionPoint);
        final inputPoint = node.output!.connectionPoints
            .firstWhereOrNull((p) => p is InputConnectionPoint);

        if (outputPoint != null && inputPoint != null) {
          final start = node.position + outputPoint.computeOffset();
          final end =
              node.output!.position + inputPoint.computeOffset();
              paint.color = Colors.red;
          _drawArrow(canvas, paint, start, end, dashed: false);
        }
      }
    }

    // 3. Draw dragging line from connection point to cursor
    if (connectionProvider.fromPoint != null &&
        connectionProvider.currentPosition != null) {
      final sourceNode =
          _findOwnerOfPoint(connectionProvider.fromPoint!, nodes);
      if (sourceNode != null) {
        final start = sourceNode.position +
            connectionProvider.fromPoint!.computeOffset();
        final end = connectionProvider.currentPosition!;
        paint.color = Colors.black.withAlpha(100);
        _drawArrow(canvas, paint, start, end, dashed: true);
      }
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end,
      {bool dashed = false}) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final cp1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final cp2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // Draw arrowhead
    final arrowSize = 8;
    final angle = atan2(end.dy - cp2.dy, end.dx - cp2.dx);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6))
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6));
    canvas.drawPath(arrowPath, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6;
    const dashSpace = 4;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  NodeModel? _findOwnerOfPoint(
      ConnectionPointModel point, List<NodeModel> nodes) {
    for (var node in nodes) {
      if (node.connectionPoints.contains(point)) {
        return node;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
