import 'dart:developer';

import 'package:flutter/cupertino.dart';

class CustomZoomPan extends StatefulWidget {
  final Widget child;
  const CustomZoomPan({super.key, required this.child});

  @override
  State<CustomZoomPan> createState() => _CustomZoomPanState();
}

class _CustomZoomPanState extends State<CustomZoomPan> {
  Offset _offset = Offset.zero;
  final double _scale = 1.0;

  Offset? _startFocalPoint;
  Offset? _startOffset;
  double? _startScale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        log('is panning');
        _startFocalPoint = details.globalPosition;
        _startOffset = _offset;
      },
      onPanUpdate: (details) {
        final delta = details.globalPosition - _startFocalPoint!;
        setState(() {
          _offset = _startOffset! + delta;
        });
        log('ispanning2');
      },
      child: ClipRect(
        child: Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: widget.child,
        ),
      ),
    );
  }
}
