import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/ui_button_wrapper.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class TwoButtonConfigWidget extends StatelessWidget {
  final TwoButtonConfiguration twoButtons;
  const TwoButtonConfigWidget({super.key, required this.twoButtons});

  @override
  Widget build(BuildContext context) {
    return twoButtons.buildWidget();
  }
}

class TwoButtonConfiguration extends UIElement {
  TwoButtonConfiguration({super.alignment = Alignment.centerRight})
      : super(

          type: UIElementType.twoButtons,
        );
  @override
  Widget buildUIElementController() {
    // TODO: implement buildUIElementController
    throw UnimplementedError();
  }

  @override
  Widget buildWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HoldButton().buildWidget(),
          SizedBox(
            width: 50,
          ),
          HoldButton().buildWidget(),
        ],
      ),
    );
  }
}
