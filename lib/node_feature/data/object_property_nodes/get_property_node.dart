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

class GetPropertyFromEntityNode extends OutputNode {
  String entityName;
  Property selectedProperty;
  bool hasTwoOutputs;

  GetPropertyFromEntityNode({
    this.entityName = '',
    this.selectedProperty = Property.position,
    this.hasTwoOutputs = true,
    super.position,
  }) : super(
          image: '',
          color: Colors.teal,
          width: 180,
          height: 120,
          connectionPoints: [
            OutputConnectionPoint(position: Offset.zero, width: 30),
            OutputConnectionPoint(position: Offset.zero, width: 30),
          ],
        );

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
  Result execute([Entity? activeEntity]) {
    final value = _getPropertyValue();
    return Result.success(result: value);
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
    NodeModel? input,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return GetPropertyFromEntityNode(
      entityName: entityName ?? this.entityName,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      hasTwoOutputs: hasTwoOutputs ?? this.hasTwoOutputs,
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..input = null
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  NodeModel copy() {
    return copyWith(
      position: position,
      entityName: entityName,
      selectedProperty: selectedProperty,
      hasTwoOutputs: hasTwoOutputs,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      input: input?.copy(),
    ) as GetPropertyFromEntityNode;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'GetPropertyFromEntityNode';
    map['entityName'] = entityName;
    map['selectedProperty'] = selectedProperty.name; // Save as string
    map['hasTwoOutputs'] = hasTwoOutputs;
    return map;
  }

  static GetPropertyFromEntityNode fromJson(Map<String, dynamic> json) {
    return GetPropertyFromEntityNode(
      entityName: json['entityName'] ?? '',
      selectedProperty: Property.values.firstWhere(
        (e) => e.name == json['selectedProperty'],
        orElse: () => Property.position,
      ),
      hasTwoOutputs: json['hasTwoOutputs'] ?? false,
      position: OffsetJson.fromJson(json['position'])
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false
      ..connectionPoints = (json['connectionPoints'] as List)
          .map((e) => ConnectionPointModel.fromJson(e))
          .toList();
  }
}
