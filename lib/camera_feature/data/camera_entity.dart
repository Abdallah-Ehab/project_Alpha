import 'dart:ui';

import 'package:scratch_clone/entity/data/entity.dart';

class CameraEntity extends Entity{
  double zoom;
  bool isEditorCamera;
  CameraEntity({
    required super.name,
    required super.position,
    required super.rotation,
    super.width = 500,
    super.height = 500,
    super.layerNumber = 0,
    this.zoom = 1.0,
    this.isEditorCamera = true,
  });

  void pan(Offset delta) {
    position += delta;
    notifyListeners();
  }

  void setZoom(double newZoom) {
    zoom = newZoom.clamp(0.2, 4.0);
    notifyListeners();
  }
}