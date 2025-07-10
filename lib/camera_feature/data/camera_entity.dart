import 'dart:ui';
import 'package:scratch_clone/entity/data/entity.dart';


class CameraEntity extends Entity {
  double zoom = 1.0;
  Size viewportSize = Size.zero;
  bool isActive;
  bool isEditorCamera;
  
  CameraEntity({
    super.tag = 'camera',
    required super.name,
    required super.position,
    required super.rotation,
    super.width = 500,
    super.height = 500,
    super.layerNumber,
    this.zoom = 1.0,
    this.isEditorCamera = true,
    this.isActive = false
  });

  factory CameraEntity.fromJson(Map<String, dynamic> json) {
    return CameraEntity(
      tag: json['tag'] as String,
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
      'tag' : 'camera',
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

  

  void setViewportSize(Size size) {
    viewportSize = size;
    notifyListeners();
  }

  void pan(Offset delta) {
  position += delta;
    notifyListeners();
  }

  void setZoom(double newZoom) {
    zoom = newZoom.clamp(0.1, 5.0);
    notifyListeners();
  }

  void zoomAt(Offset point, double delta) {
    final newZoom = (zoom * delta).clamp(0.1, 5.0);
    final zoomFactor = newZoom / zoom;
    position = point - (point - position) * zoomFactor;
    zoom = newZoom;
    notifyListeners();
  }

  // Convert screen coordinates to world coordinates
  Offset screenToWorld(Offset screenPoint) {
    return (screenPoint / zoom) + position;
  }

  // Convert world coordinates to screen coordinates
  Offset worldToScreen(Offset worldPoint) {
    return (worldPoint - position) * zoom;
  }

  // Check if a world rectangle is visible in the viewport
  bool isRectVisible(Rect worldRect) {
    final viewportRect = Rect.fromLTWH(
      position.dx,
      position.dy,
    viewportSize.width / zoom,
      viewportSize.height / zoom,
    );
    return viewportRect.overlaps(worldRect);
  }

  // Get the world bounds visible in the viewport
  Rect getVisibleWorldBounds() {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      viewportSize.width / zoom,
      viewportSize.height / zoom,
    );
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




// class GameCamera extends ChangeNotifier {
//   Offset _position = Offset.zero;
//   double _zoom = 1.0;
//   Size _viewportSize = Size.zero;

//   Offset get position => _position;
//   double get zoom => _zoom;
//   Size get viewportSize => _viewportSize;

//   void setViewportSize(Size size) {
//     _viewportSize = size;
//     notifyListeners();
//   }

//   void pan(Offset delta) {
//     _position += delta;
//     notifyListeners();
//   }

//   void setZoom(double newZoom) {
//     _zoom = newZoom.clamp(0.1, 5.0);
//     notifyListeners();
//   }

//   void zoomAt(Offset point, double delta) {
//     final newZoom = (_zoom * delta).clamp(0.1, 5.0);
//     final zoomFactor = newZoom / _zoom;
//     _position = point - (point - _position) * zoomFactor;
//     _zoom = newZoom;
//     notifyListeners();
//   }

//   // Convert screen coordinates to world coordinates
//   Offset screenToWorld(Offset screenPoint) {
//     return (screenPoint / _zoom) + _position;
//   }

//   // Convert world coordinates to screen coordinates
//   Offset worldToScreen(Offset worldPoint) {
//     return (worldPoint - _position) * _zoom;
//   }

//   // Check if a world rectangle is visible in the viewport
//   bool isRectVisible(Rect worldRect) {
//     final viewportRect = Rect.fromLTWH(
//       _position.dx,
//       _position.dy,
//       _viewportSize.width / _zoom,
//       _viewportSize.height / _zoom,
//     );
//     return viewportRect.overlaps(worldRect);
//   }

//   // Get the world bounds visible in the viewport
//   Rect getVisibleWorldBounds() {
//     return Rect.fromLTWH(
//       _position.dx,
//       _position.dy,
//       _viewportSize.width / _zoom,
//       _viewportSize.height / _zoom,
//     );
//   }
// }