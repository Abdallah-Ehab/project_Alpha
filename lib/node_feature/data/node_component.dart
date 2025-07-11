import 'dart:developer';
import 'dart:ui';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';

class NodeComponent extends Component {
  NodeModel? startNode;
  late List<NodeModel> workspaceNodes;
  NodeWorkspaceCamera? _camera;
  Size? _viewportSize;

  NodeComponent(
      {super.isActive = true,
      NodeModel? startNode,
      List<NodeModel>? workspaceNodes}) {
    this.startNode = startNode ?? StartNode();
    this.workspaceNodes = workspaceNodes ?? [this.startNode!];
  }

  // Set camera for this specific node component
  void setCamera(NodeWorkspaceCamera camera, Size viewportSize) {
    _camera = camera;
    _viewportSize = viewportSize;
    notifyListeners();
  }

  // Getters for camera and viewport
  NodeWorkspaceCamera? get camera => _camera;
  Size? get viewportSize => _viewportSize;

  // Convert screen to world coordinates using component's camera
  Offset? screenToWorld(Offset screenPosition) {
    if (_camera != null && _viewportSize != null) {
      return _camera!.screenToWorld(screenPosition, _viewportSize!);
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'node_component',
        'isActive': isActive,
        'workspaceNodes':
            workspaceNodes.map((node) => node.baseToJson()).toList(),
        'startNodeId': startNode?.id,
      };

  static NodeComponent fromJson(Map<String, dynamic> json) {
    final workspaceNodesJson = json['workspaceNodes'] as List<dynamic>;

    // First pass: deserialize all nodes
    final nodeList = workspaceNodesJson
        .map((nodeJson) => NodeModel.fromJson(nodeJson as Map<String, dynamic>))
        .toList();

    // Build id -> node map
    final idToNode = <String, NodeModel>{
      for (var node in nodeList) node.id: node,
    };

    // Read start node ID
    final startNodeId = json['startNodeId'] as String?;
    NodeModel? startNode = startNodeId != null ? idToNode[startNodeId] : null;

    // Second pass: restore all connections except start node
    for (int i = 0; i < nodeList.length; i++) {
      final node = nodeList[i];
      final nodeJson = workspaceNodesJson[i] as Map<String, dynamic>;

      final childId = nodeJson['childId'];
      if (node.id == startNodeId) continue; // delay start node

      if (childId != null && idToNode.containsKey(childId)) {
        node.connectNode(idToNode[childId]!);
      }
      if (nodeJson['inputId'] != null &&
          idToNode.containsKey(nodeJson['inputId'])) {
        (node as HasInput).connectInput(idToNode[nodeJson['inputId']]!);
      }
      if (nodeJson['outputId'] != null &&
          idToNode.containsKey(nodeJson['outputId'])) {
        (node as HasOutput).connectOutput(idToNode[nodeJson['outputId']]!);
      }
    }

    // Now connect start node’s child
    if (startNode != null) {
      final startJson = workspaceNodesJson.firstWhere(
              (e) => (e as Map<String, dynamic>)['id'] == startNodeId)
          as Map<String, dynamic>;

      final childId = startJson['childId'];
      if (childId != null && idToNode.containsKey(childId)) {
        startNode.connectNode(idToNode[childId]!);
      }
    }

    // 3rd pass to connect value nodes
    final allPoints = nodeList
        .whereType<InputNodeWithValue>()
        .expand((n) => n.connectionPoints)
        .whereType<ValueConnectionPoint>()
        .toList();
    final idToPoint = {
      for (final p in allPoints) p.id: p,
    };

    for (final point in allPoints) {
      final dynamic p = point;

      final sourceId = p._sourcePointId;
      final destinationId = p._destinationPointId;

      if (sourceId != null && idToPoint[sourceId] is ValueConnectionPoint) {
        p.sourcePoint = idToPoint[sourceId] as ValueConnectionPoint;
      }

      if (destinationId != null &&
          idToPoint[destinationId] is ValueConnectionPoint) {
        p.destinationPoint = idToPoint[destinationId] as ValueConnectionPoint;
      }

      // Mark connection state
      point.isConnected = p.sourcePoint != null;
        }
    return NodeComponent(
      isActive: json['isActive'] as bool? ?? true,
      startNode: startNode,
      workspaceNodes: nodeList,
    );
  }

  void addNodeToWorkspace(NodeModel node) {
    workspaceNodes.add(node);
    startNode ??= node;
    notifyListeners();
  }

  void removeNodeFromWorkspace(NodeModel node) {
    if (startNode == node) return;
    workspaceNodes.remove(node);
    notifyListeners();
  }

  NodeModel? _current;
  @override
  void update(Duration dt, {required Entity activeEntity}) {
    _current = startNode;

    while (_current != null) {
      log('${_current?.child} is child of $_current of id : ${_current?.id}');
      final result = _current!.execute(activeEntity);
      if (result.errorMessage != null) {
        log("Execution error: ${result.errorMessage}");
        break;
      }

      // Special case: IfNode false condition
      if (_current is IfNode &&
          result is Result<bool> &&
          result.result == false) {
        final elseNode = _current!.child;
        if (elseNode is ElseNode) {
          final elseResult = elseNode.execute(activeEntity);
          if (elseResult.errorMessage != null) {
            log("Else block error: ${elseResult.errorMessage}");
            break;
          }
          _current = elseNode.child;
          continue;
        }
      }

      _current = _current!.child;
    }

    notifyListeners();
  }

  @override
  void reset() {
    _current = startNode;
    notifyListeners();
  }

  @override
  NodeComponent copy() {
    // Step 1: Copy all nodes (new UUIDs, connections lost)
    final copiedNodes = workspaceNodes.map((node) => node.copy()).toList();

    // Step 2: Restore connections using index-matching
    for (int i = 0; i < workspaceNodes.length; i++) {
      final original = workspaceNodes[i];
      final copy = copiedNodes[i];

      // Connect child
      if (original.child != null) {
        final childIndex = workspaceNodes.indexOf(original.child!);
        if (childIndex != -1) {
          copy.connectNode(copiedNodes[childIndex]);
        }
      }

      // Connect input
      if (original is HasInput && (original).input != null) {
        final inputIndex =
            workspaceNodes.indexOf((original).input!);
        if (inputIndex != -1 && copy is HasInput) {
          copy.connectInput(copiedNodes[inputIndex]);
        }
      }

      // Connect output
      if (original is HasOutput && (original).output != null) {
        final outputIndex =
            workspaceNodes.indexOf((original).output!);
        if (outputIndex != -1 && copy is HasOutput) {
          copy.connectOutput(copiedNodes[outputIndex]);
        }
      }
    }

    // Step 3: Copy start node reference
    NodeModel? newStartNode;
    if (startNode != null) {
      final startIndex = workspaceNodes.indexOf(startNode!);
      if (startIndex != -1) {
        newStartNode = copiedNodes[startIndex];
      }
    }

    return NodeComponent(
      isActive: isActive,
      startNode: newStartNode,
      workspaceNodes: copiedNodes,
    );
  }
}
