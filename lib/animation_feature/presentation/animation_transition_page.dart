import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationTransitionsPage extends StatelessWidget {
  const AnimationTransitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(builder: (context, entity, _) {
      final animComp = entity.getComponent<AnimationControllerComponent>();
      if (animComp == null) {
        return const Center(child: Text("No animation component"));
      }

      return ChangeNotifierProvider.value(
        value: animComp,
        child: Consumer<AnimationControllerComponent>(
            builder: (context, value, child) {
          return ListView.builder(
            itemCount: animComp.transitions.length,
            itemBuilder: (context, index) {
              final transition = animComp.transitions[index];
              return _buildTransitionCard(context, animComp, transition, index);
            },
          );
        }),
      );
    });

    // ✨ Dual Floating Buttons: Visualize (top), Add (bottom)
  }

  /// Builds a single transition card.
  Widget _buildTransitionCard(BuildContext context,
      AnimationControllerComponent animComp, Transition transition, int index) {
    return Card(
      color: Color(0xff222222),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              "${transition.condition.entityVariable} ${transition.condition.operator} ${transition.condition.secondOperand}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "PressStart2P",
                  color: Colors.white,
                  fontSize: 18),
            ),
            Text(
              ":",
              style: TextStyle(
                  fontFamily: "PressStart2P",
                  color: Colors.white,
                  fontSize: 18),
            ),
            const SizedBox(width: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xff222222),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transition.startTrackName,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "PressStart2P",
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // _bubble(transition.startTrackName, Color(0xff888888)),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transition.targetTrackName,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "PressStart2P",
                    color: Color(0xff333333),
                    fontWeight: FontWeight.bold),
              ),
            ),
            // _bubble(transition.targetTrackName, Colors.red),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                animComp.removeTransitionAtIndex(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a track label bubble.
Widget _bubble(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withAlpha(100),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
          fontSize: 12,
          fontFamily: "PressStart2P",
          color: color,
          fontWeight: FontWeight.bold),
    ),
  );
}
