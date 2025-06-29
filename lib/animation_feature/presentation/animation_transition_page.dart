
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationTransitionsPage extends StatelessWidget {
  const AnimationTransitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(
      builder: (context, entity, _) {
        final animComp = entity.getComponent<AnimationControllerComponent>();
        if (animComp == null) {
          return const Center(child: Text("No animation component"));
        }

        return
           ChangeNotifierProvider.value(
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
               } 
             ),
           );});

          // ✨ Dual Floating Buttons: Visualize (top), Add (bottom)
          
  }

  /// Builds a single transition card.
  Widget _buildTransitionCard(BuildContext context, AnimationControllerComponent animComp, Transition transition, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _bubble(transition.startTrackName, Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${transition.condition.entityVariable} ${transition.condition.operator} ${transition.condition.secondOperand}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            _bubble(transition.targetTrackName, Colors.red),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                animComp.removeTransitionAtIndex(index);
              },
            ),
          ],
        ),
      ),
    );
  }}

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
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

