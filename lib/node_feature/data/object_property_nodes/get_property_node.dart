import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/object_property_node_widgets/get_property_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class GetPropertyFromEntityNode extends InputNodeWithValue {
  String entityName;
  Property selectedProperty;
  bool hasTwoOutputs;

  GetPropertyFromEntityNode({
    this.entityName = '',
    this.selectedProperty = Property.position,
    this.hasTwoOutputs = true,
    super.position,
  }) : super(
          image: 'assets/icons/GetPropertyFromEntityNode.png',
          color: Colors.teal,
          width: 180,
          height: 120,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ValueConnectionPoint(
        position: Offset.zero,
        valueIndex: 0,
        width: 30,
        isLeft: false,
        ownerNode: this,
      ),
      ValueConnectionPoint(
        position: Offset.zero,
        valueIndex: 1,
        width: 30,
        isLeft: false,
        ownerNode: this,
      ),
    ];
  }

  void setEntityName(String name) {
    entityName = name;
    notifyListeners();
  }

  void setProperty(Property property) {
    selectedProperty = property;
    hasTwoOutputs = selectedProperty == Property.position;
    notifyListeners();
  }

  dynamic _getPropertyValue() {
    final entity = EntityManager().getActorByName(entityName);
    if (entity == null) return null;
    return entity.getProperty(selectedProperty);
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    final value = _getPropertyValue();

    if (selectedProperty == Property.position && value is Offset) {
      (connectionPoints[0] as ValueConnectionPoint).value = value.dx;
      (connectionPoints[1] as ValueConnectionPoint).value = value.dy;
      return Result.success(result: [value.dx, value.dy]);
    } else {
      (connectionPoints[0] as ValueConnectionPoint).value = value;
      (connectionPoints[1] as ValueConnectionPoint).value = null;
      return Result.success(result: [value]);
    }
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: GetPropertyFromEntityNodeWidget(nodeModel: this),
    );
  }

  @override
  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    String? entityName,
    Property? selectedProperty,
    bool? hasTwoOutputs,
    NodeModel? sourceNode,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = GetPropertyFromEntityNode(
      entityName: entityName ?? this.entityName,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      hasTwoOutputs: hasTwoOutputs ?? this.hasTwoOutputs,
      position: position ?? this.position,
    );

    newNode.isConnected = isConnected ?? this.isConnected;
    newNode.child = null;
    newNode.parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints
            .map((cp) => cp.copyWith(ownerNode: newNode))
            .toList()
        : this
            .connectionPoints
            .map((cp) => cp.copyWith(ownerNode: newNode))
            .toList();

    return newNode;
  }

  @override
  NodeModel copy() {
    return copyWith() as GetPropertyFromEntityNode;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'GetPropertyFromEntityNode';
    map['entityName'] = entityName;
    map['selectedProperty'] = selectedProperty.name;
    map['hasTwoOutputs'] = hasTwoOutputs;
    return map;
  }

  static GetPropertyFromEntityNode fromJson(Map<String, dynamic> json) {
    final node = GetPropertyFromEntityNode(
      entityName: json['entityName'] ?? '',
      selectedProperty: Property.values.firstWhere(
        (e) => e.name == json['selectedProperty'],
        orElse: () => Property.position,
      ),
      hasTwoOutputs: json['hasTwoOutputs'] ?? false,
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
