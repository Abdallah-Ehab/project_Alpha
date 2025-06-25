import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';

class ConnectionProvider with ChangeNotifier {
  ConnectionPointModel? fromPoint;
  Offset? currentPosition;

  void startConnection(ConnectionPointModel point) {
    fromPoint = point;
    notifyListeners();
  }

  void updatePosition(Offset position) {
    currentPosition = position;
    notifyListeners();
  }

  void clear() {
    fromPoint = null;
    currentPosition = null;
    notifyListeners();
  }
}
