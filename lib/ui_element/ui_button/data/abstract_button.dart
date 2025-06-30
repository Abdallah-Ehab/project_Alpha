import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

abstract class UIButtonElement extends UIElement with ChangeNotifier {
  String? entityName;
  String variableName;
  dynamic valueToSet;

  UIButtonElement({
    this.entityName,
    this.variableName = '',
    this.valueToSet,
    super.alignment = Alignment.centerLeft,
  });

  void trigger({required bool down});

  void setVariable(bool value) {
    if (entityName == null) return;
    final entity = EntityManager().getActorByName(entityName!);
    if (entity == null) return;
    if (!entity.variables.containsKey(variableName)) return;
    entity.setVariableXToValueY(variableName, value);
  }

  @override
  Widget buildUIElementController(); // Each subclass should implement this

  @override
  String toString() =>
      'UIButtonElement(entityName: $entityName, variableName: $variableName, valueToSet: $valueToSet)';

  @override
  bool operator ==(covariant UIButtonElement other) {
    if (identical(this, other)) return true;

    return other.entityName == entityName &&
        other.variableName == variableName &&
        other.valueToSet == valueToSet;
  }

 bool _onCooldown = false;

void triggerOnce({
  Duration activeDuration = const Duration(milliseconds: 100),
  Duration cooldown = const Duration(milliseconds: 300),
}) {
  if (_onCooldown || entityName == null) return;

  final entity = EntityManager().getActorByName(entityName!);
  if (entity == null) return;
  if (!entity.variables.containsKey(variableName)) return;

  // Set to true
  entity.setVariableXToValueY(variableName, true);
  _onCooldown = true;

  // Reset after activeDuration
  Future.delayed(activeDuration, () {
    entity.setVariableXToValueY(variableName, false);
  });

  // Cooldown reset
  Future.delayed(cooldown, () {
    _onCooldown = false;
  });
}


  @override
  int get hashCode =>
      entityName.hashCode ^ variableName.hashCode ^ valueToSet.hashCode;
}
