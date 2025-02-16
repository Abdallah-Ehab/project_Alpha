import 'package:flutter/material.dart';
import 'package:scratch_clone/widgets/animationWidgets/animation_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/time_line_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/tweening_slider.dart';

class AnimationEditorScreen extends StatelessWidget {
  const AnimationEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const Drawer(
        backgroundColor: Colors.transparent,
        child: Center(child: TweeningSlider()),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Animationwidget(),
            TimeLineWidget(),
          ],
        ),
      ),
    );
  }
}