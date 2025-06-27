import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/object_property_nodes/get_property_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension GetPropertyFromEntityNodeSerialization on GetPropertyFromEntityNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'GetPropertyFromEntityNode',
      'entityName': entityName,
      'selectedProperty': selectedProperty.name,
      'hasTwoOutputs': hasTwoOutputs,
    });

  static GetPropertyFromEntityNode fromJson(Map<String, dynamic> json) => GetPropertyFromEntityNode(
        position: OffsetJson.fromJson(json['position']),
        entityName: json['entityName'],
        selectedProperty: Property.values.byName(json['selectedProperty']),
        hasTwoOutputs: json['hasTwoOutputs'],
      );
}