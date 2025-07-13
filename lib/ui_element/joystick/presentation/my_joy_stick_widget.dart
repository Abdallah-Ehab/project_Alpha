import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/joystick/data/joy_stick_element.dart';


class MyJoyStickWidget extends StatelessWidget {
  final JoyStickElement joyStickElement;
  const MyJoyStickWidget({super.key, required this.joyStickElement});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(builder: (context, value, child) {
      final isPlaying = value.isPlaying;
      if (isPlaying) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Joystick(
          includeInitialAnimation: false,
          listener: (details) {
            joyStickElement.control(details.x, details.y);
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => joyStickElement.buildUIElementController(),
          );
        },
        child: const JoystickStick(), // Assuming JoystickStick is your placeholder widget
      );
    }
    },);

    
  }
}