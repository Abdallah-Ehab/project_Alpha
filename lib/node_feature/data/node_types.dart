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
  void connectValue(NodeModel node) {
    if (this == node) return;
    sourceNode = node;
    notifyListeners();
  }

  void disconnect() {
    sourceNode = null;
    notifyListeners();
  }
}

mixin HasMultipleInputs on NodeModel {
  final List<NodeModel?> inputs = [];

  void connectInput(int index, NodeModel node) {
    if (this == node) return;
    while (inputs.length <= index) {
      inputs.add(null);
    }
    inputs[index] = node;
    notifyListeners();
  }

  void disconnectInput(int index) {
    if (index < inputs.length) {
      inputs[index] = null;
      notifyListeners();
    }
  }

  NodeModel? getInput(int index) {
    if (index < inputs.length) {
      return inputs[index];
    }
    return null;
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

abstract class MultipleInputNode extends NodeModel with HasMultipleInputs,HasOutput {
  MultipleInputNode({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}


abstract class InputNodeWithValue extends NodeModel with HasValue,HasOutput {
  InputNodeWithValue({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}

abstract class OutputNodeWithValue extends NodeModel with HasValue,HasInput{
  OutputNodeWithValue({super.position,required super.color, required super.width, required super.height, required super.connectionPoints,required super.image});
}


 
