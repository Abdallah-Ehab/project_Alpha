import 'dart:ui';

Offset lerpOffset(Offset start, Offset end, double t) {
  return Offset(
    start.dx + (end.dx - start.dx) * t,
    start.dy + (end.dy - start.dy) * t,
  );
}

double lerpDouble(double start, double end, double t) {
  return start + (end - start) * t;
}