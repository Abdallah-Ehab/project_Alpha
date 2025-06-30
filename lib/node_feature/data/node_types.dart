import 'package:scratch_clone/node_feature/data/node_model.dart';


mixin HasInput on NodeModel {
  NodeModel? input;
  
  void connectInput(NodeModel node) {
    if (this == node) return;
    input = node;
    notifyListeners();
  }

  void disconnectInput() {
    input = null;
    notifyListeners();
  }
}

mixin HasOutput on NodeModel {
  NodeModel? output;

  void connectOutput(NodeModel node) {
    if (this == node) return;
    output = node;
    notifyListeners();
  }

  void disconnectOutput() {
    output = null;
    notifyListeners();
  }
}

mixin HasValue on NodeModel{
  NodeModel? sourceNode;
  void disconnect() {
    sourceNode = null;
    isConnected = false;
    notifyListeners();
  }
}





abstract class InputNode extends NodeModel with HasOutput {
  InputNode({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}

abstract class OutputNode extends NodeModel with HasInput {
  OutputNode({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}

abstract class InputOutputNode extends NodeModel with HasInput, HasOutput {
  InputOutputNode({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}
