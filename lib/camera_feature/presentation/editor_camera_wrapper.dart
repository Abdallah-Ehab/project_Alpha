import 'package:flutter/widgets.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';

class EditorCameraWrapper extends StatelessWidget {
  final CameraEntity camera;
  final Widget child;

  const EditorCameraWrapper({
    super.key,
    required this.camera,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Capture gestures even in transparent areas
      onPanUpdate: (details) {
        camera.pan(-details.delta / camera.zoom);
      },
      child: SizedBox.expand(
        child: child,
      ),
    );
  }
}
