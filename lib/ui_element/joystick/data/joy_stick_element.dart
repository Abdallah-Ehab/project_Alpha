
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/joystick/presentation/joy_stick_control_panel.dart';
import 'package:scratch_clone/ui_element/joystick/presentation/my_joy_stick_widget.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

// so I'm thinking about adding something new the ui elements the ui elements interact with the entity and its variables 
// for example when you think about a health bar (the player,health variable)
// or a joystick (the player,velocity variable)
// so I'm thinking about creating an abstract class called UIElement and inside this class an abstract function called control that takes an entity and a variable name as parameters and then the UIElement will have a function called setVariable that will set the variable of the entity to the value of the UIElement
// and then the UIElement will have a function called getVariable that will get the variable of the entity and set it to the value of the UIElement
class JoyStickElement extends UIElement with ChangeNotifier {
  String? entityName;
  double xValue;
  double yValue;
  String xName;
  String yName; 
  bool allowGlobals;
  
  JoyStickElement({
    required super.alignment,
    super.type = UIElementType.joystick,  
    this.entityName,
    this.xValue = 0,
    this.yValue = 0,
    this.xName = "x",
    this.yName = "y",
    this.allowGlobals = false,
  });
  
  void _setVariableValue(String variableName, double value, Entity? entity) {
    if (allowGlobals) {
      // Check global variables first (favor global over entity)
      if (EntityManager().globalVariables.containsKey(variableName)) {
        EntityManager().setGlobalVariable(variableName, value);
        return;
      }
    }
    
    // Then check entity variables
    if (entity != null && entity.variables.containsKey(variableName)) {
      entity.setVariableXToValueY(variableName, value);
    }
  }
  
  Result<String> control(double xValue, double yValue) {
    if (entityName != null) {
      Entity? entity = EntityManager().getActorByName(entityName!);
      if (entity == null) {
        return Result.failure(errorMessage: "entity is null");
      }
      
      // Set X variable
      _setVariableValue(xName, xValue, entity);
      
      // Set Y variable
      _setVariableValue(yName, yValue, entity);
    } else {
      return Result.failure(errorMessage: "entityName is null");
    }
    return Result.success(result: "xValue is $xValue and yValue is $yValue");
  }
  
  void setEntityName(String name) {
    entityName = name;
    notifyListeners();
  }
  
  void setXName(String name) {
    xName = name;
    notifyListeners();
  }
  
  void setYName(String name) {
    yName = name;
    notifyListeners();
  }
  
  void setAllowGlobals(bool value) {
    allowGlobals = value;
    notifyListeners();
  }
  
  @override
  Widget buildUIElementController() {
    return ChangeNotifierProvider.value(value: this,child: JoyStickControlPanel(joyStickElement: this,));
  }
  
  @override
  Widget buildWidget() {
    return MyJoyStickWidget(joyStickElement: this);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'alignment': alignmentToJson(alignment),
      'entityName': entityName,
      'xValue': xValue,
      'yValue': yValue,
      'xName': xName,
      'yName': yName,
      'allowGlobals': allowGlobals,
    };
  }

  static JoyStickElement fromJson(Map<String, dynamic> json) {
    return JoyStickElement(
      alignment: alignmentFromJson(json['alignment']),
      entityName: json['entityName'],
      xValue: (json['xValue'] ?? 0).toDouble(),
      yValue: (json['yValue'] ?? 0).toDouble(),
      xName: json['xName'] ?? "x",
      yName: json['yName'] ?? "y",
      allowGlobals: json['allowGlobals'] ?? false,
    );
  }
}