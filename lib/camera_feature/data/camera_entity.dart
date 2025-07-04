import 'dart:ui';
import 'package:scratch_clone/entity/data/entity.dart';


class CameraEntity extends Entity {
  double zoom;
  bool isEditorCamera;

  CameraEntity({
    required super.name,
    required super.position,
    required super.rotation,
    super.width = 500,
    super.height = 500,
    super.layerNumber,
    this.zoom = 1.0,
    this.isEditorCamera = true,
  });

  factory CameraEntity.fromJson(Map<String, dynamic> json) {
    return CameraEntity(
      name: json['name'] as String,
      position: Entity.offsetFromJson(json['position'] as Map<String, dynamic>),
      rotation: (json['rotation'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 500,
      height: (json['height'] as num?)?.toDouble() ?? 500,
      layerNumber: json['layerNumber'] as int? ?? 0,
      zoom: (json['zoom'] as num?)?.toDouble() ?? 1.0,
      isEditorCamera: json['isEditorCamera'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'camera',
      'name': name,
      'position': Entity.offsetToJson(position),
      'rotation': rotation,
      'width': width,
      'height': height,
      'layerNumber': layerNumber,
      'zoom': zoom,
      'isEditorCamera': isEditorCamera,
    };
  }

  void pan(Offset delta) {
    position += delta;
    notifyListeners();
  }

  void setZoom(double newZoom) {
    zoom = newZoom.clamp(0.2, 4.0);
    notifyListeners();
  }

  @override
  CameraEntity copy() {
    return CameraEntity(
      name: name,
      position: position,
      rotation: rotation,
      width: width,
      height: height,
      layerNumber: layerNumber,
      zoom: zoom,
      isEditorCamera: isEditorCamera,
    )
      ..components = {
        for (final entry in components.entries)
          entry.key: [for(final component in entry.value) component.copy()], // assumes each component has a .copy()
      }
      ..variables = Map<String, dynamic>.from(variables)
      ..widthScale = widthScale
      ..heigthScale = heigthScale;
  }
}
