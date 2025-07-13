import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/text_config_dialog.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/ui_text_element_widget.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class TextElement extends UIElement with ChangeNotifier {
  String? boundVariable;
  String? entityName;
  String? fontFamily;
  String? value;
  Color? color;

  TextElement({
    required super.alignment,
    this.boundVariable,
    this.color = Colors.black,
    this.entityName,
    this.fontFamily = 'PressStart2P',
    this.value,
  }) : super(type: UIElementType.text);

  @override
  Widget buildWidget() {
    return UiTextElementWidget(text : this);
  }

  @override
  Widget buildUIElementController() {
    return TextElementConfigDialog(
      textElement: this,
    );
  }

  void setEntityName(String name){
    entityName = name;
    notifyListeners();
  }

  void setVariable(String name){
    boundVariable = name;
    notifyListeners();
  }

  void setFont(String name){
    fontFamily = name;
    notifyListeners();
  }

  void setColor(Color color){
    this.color = color;
    notifyListeners();
  }
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
