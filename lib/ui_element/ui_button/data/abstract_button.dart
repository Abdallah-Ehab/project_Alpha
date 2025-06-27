import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

abstract class UIButtonElement extends UIElement with ChangeNotifier{
  String? entityName;
  String variableName;
  dynamic valueToSet;

  UIButtonElement({
    this.entityName,
    this.variableName = '',
    this.valueToSet, required Alignment alignment,
  });

  void trigger({required bool down});


  void setVariable(dynamic value) {
    if (entityName == null) return;
    final entity = EntityManager().getActorByName(entityName!);
    if (entity == null) return;
    if (!entity.variables.containsKey(variableName)) return;
    entity.setVariableXToValueY(variableName, value);
  }

  @override
  Widget buildUIElementController(); // Each subclass should implement this

  @override
  String toString() => 'UIButtonElement(entityName: $entityName, variableName: $variableName, valueToSet: $valueToSet)';

  @override
  bool operator ==(covariant UIButtonElement other) {
    if (identical(this, other)) return true;
  
    return 
      other.entityName == entityName &&
      other.variableName == variableName &&
      other.valueToSet == valueToSet;
  }

  @override
  int get hashCode => entityName.hashCode ^ variableName.hashCode ^ valueToSet.hashCode;
}
