import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';

class ConnectionProvider with ChangeNotifier {
  ConnectionPointModel? fromPoint;
  Offset? currentPosition;
  NodeWorkspaceCamera? _camera;
  Size? _viewportSize;

  void setCamera(NodeWorkspaceCamera camera, Size viewportSize) {
    _camera = camera;
    _viewportSize = viewportSize;
  }

  void startConnection(ConnectionPointModel point) {
    fromPoint = point;
    notifyListeners();
  }

  void updatePosition(Offset screenPosition) {
    if (_camera != null && _viewportSize != null) {
      // Convert screen to world coordinates
      currentPosition = _camera!.screenToWorld(screenPosition, _viewportSize!);
      notifyListeners();
    }
  }

  NodeWorkspaceCamera? get camera => _camera;
  Size? get viewportSize => _viewportSize;

  void clear() {
    fromPoint = null;
    currentPosition = null;
    notifyListeners();
  }
}
