import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class AnimationTrackControlPanel extends StatelessWidget {
  const AnimationTrackControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    return ChangeNotifierProvider.value(
      value: entityManager.activeEntity,
      child: Consumer<Entity>(
        builder: (context, entity, _) {
          final animComp = entity.getComponent<AnimationControllerComponent>();
          if (animComp == null) {
            return const Text("No Animation Component");
          }
      
          return ChangeNotifierProvider.value(
            value: animComp,
            child: Consumer<AnimationControllerComponent>(
              builder: (context, animComp, child) {
                final currentTrack = animComp.currentAnimationTrack;
                final trackNames = animComp.animationTracks.keys.toList();
      
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                        color: Color(0xff888888),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButton<String>(
                                dropdownColor: const Color(0xff888888),
                                borderRadius: BorderRadius.circular(16),
                                value: currentTrack.name,
                                items: trackNames.map((name) {
                                  return DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          fontFamily: "PressStart2P",
                                          fontSize: 14,
                                          color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selected) {
                                  if (selected == null ||
                                      selected == currentTrack.name) return;
                                  final newTrack =
                                      animComp.animationTracks[selected]!;
      
                                  // Clamp frame index
                                  if (animComp.currentFrame >=
                                      newTrack.frames.length) {
                                    animComp.setFrame(newTrack.frames.length - 1);
                                  }
                                  animComp.setTrack(selected);
                                },
                              ),
                            ),
      
                            // Track name + delete
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Track: ${currentTrack.name}",
                                      style: TextStyle(
                                          fontFamily: "PressStart2P",
                                          fontSize: 12,
                                          color: Colors.white)),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (animComp.animationTracks.length <= 1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "At least one animation track must exist.",
                                              style: TextStyle(
                                                  fontFamily: "PressStart2P",
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                        ));
                                        return;
                                      }
      
                                      final currentName = currentTrack.name;
                                      animComp.animationTracks
                                          .remove(currentName);
      
                                      // Fallback
                                      final fallback =
                                          animComp.animationTracks.keys.first;
                                      animComp.setTrack(fallback);
                                      animComp.setFrame(0);
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    // Dropdown to switch tracks
      
                    Card(
                        color: Color(0xff888888),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ChangeNotifierProvider.value(
                                value: currentTrack,
                                child: Consumer<AnimationTrack>(
                                  builder: (context, currentTrack, child) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Position",
                                              style: TextStyle(
                                                  fontFamily: "PressStart2P",
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                          const SizedBox(height: 8),
                                          Divider(),
                                          const SizedBox(height: 8),
                                          // X Position Slider
                                          Row(
                                            children: [
                                              const Text("X:",
                                                  style: TextStyle(
                                                      fontFamily: "PressStart2P",
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                              Expanded(
                                                child: PixelatedSlider(
                                                  value: currentTrack.position.dx,
                                                  min: -300.0,
                                                  max: 300.0,
                                                  divisions: 600,
                                                  label: currentTrack.position.dx
                                                      .round()
                                                      .toString(),
                                                  onChanged: (value) {
                                                    currentTrack.setPosition(
                                                        Offset(
                                                            value,
                                                            currentTrack
                                                                .position.dy));
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  currentTrack.position.dx
                                                      .round()
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: "PressStart2P",
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
      
                                          // Y Position Slider
                                          Row(
                                            children: [
                                              const Text(
                                                "Y:",
                                                style: TextStyle(
                                                    fontFamily: "PressStart2P",
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                              Expanded(
                                                child: PixelatedSlider(
                                                  value: currentTrack.position.dy,
                                                  min: -300.0,
                                                  max: 300.0,
                                                  divisions: 600,
                                                  label: currentTrack.position.dy
                                                      .round()
                                                      .toString(),
                                                  onChanged: (value) {
                                                    currentTrack.setPosition(
                                                        Offset(
                                                            currentTrack
                                                                .position.dx,
                                                            value));
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  currentTrack.position.dy
                                                      .round()
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: "PressStart2P",
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
      
                                          // Reset Position Button
                                          Center(
                                            child: Card(
                                              color: Color(0xff555555),
                                              child: TextButton(
                                                onPressed: () {
                                                  currentTrack
                                                      .setPosition(Offset.zero);
                                                },
                                                child: const Text(
                                                  "Reset Position",
                                                  style: TextStyle(
                                                      fontFamily: "PressStart2P",
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
      
                    // Position Controls
      
                    const Divider(),
      
                    Card(
                      color: Color(0xff888888),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ChangeNotifierProvider.value(
                              value: currentTrack,
                              child: Consumer<AnimationTrack>(
                                builder: (context, currentTrack, child) =>
                                    CheckboxListTile(
                                  title: const Text("Looping",style: TextStyle(
                                                        fontFamily: "PressStart2P",
                                                        fontSize: 14,
                                                        color: Colors.white),),
                                  value: currentTrack.isLooping,
                                  onChanged: (value) {
                                    currentTrack.setIsLooping(value ?? false);
                                  },
                                ),
                              ),
                            ),
                            Divider(),
                        
                            ChangeNotifierProvider.value(
                              value: currentTrack,
                              child: Consumer<AnimationTrack>(
                                builder: (context, currentTrack, child) =>
                                    CheckboxListTile(
                                  title: const Text("Must Finish Before Transition",style: TextStyle(
                                                        fontFamily: "PressStart2P",
                                                        fontSize: 12,
                                                        color: Colors.white),),
                                  value: currentTrack.mustFinish,
                                  onChanged: (value) {
                                    currentTrack.setMustFinish(value ?? false);
                                  },
                                ),
                              ),
                            ),
                            Divider(),
                        
                            // Destroy Animation Checkbox
                            ChangeNotifierProvider.value(
                              value: currentTrack,
                              child: Consumer<AnimationTrack>(
                                builder: (context, currentTrack, child) =>
                                    CheckboxListTile(
                                  title: const Text("Destroy Animation",style: TextStyle(
                                                        fontFamily: "PressStart2P",
                                                        fontSize: 12,
                                                        color: Colors.white),),
                                  subtitle: const Text(
                                      "Automatically creates transitions from all other animations",style: TextStyle(
                                                        fontFamily: "PressStart2P",
                                                        fontSize: 10,
                                                        color: Colors.white),),
                                  value: currentTrack.isDestroyAnimationTrack,
                                  onChanged: (value) {
                                    if (value == true) {
                                      animComp
                                          .markAsDestroyAnimation(currentTrack.name);
                                    } else {
                                      animComp.unmarkAsDestroyAnimation(
                                          currentTrack.name);
                                    }
                                  },
                                ),
                              ),
                            ),
                            Divider(),
                        
                            // Trigger Destroy Button (for testing)
                            if (animComp.hasDestroyAnimation())
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    animComp.triggerDestroy(entity);
                                  },
                                  child: const Text("Trigger Destroy (Test)"),
                                ),
                              ),
                        
                            const Divider(),
                        
                            // Add new track
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.add_circle_outline,color: Colors.white,),
                                tooltip: "Add Animation Track",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        _buildAddTrackDialog(context, animComp),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
      
                    // Checkboxes for looping, mustFinish, and destroy animation
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddTrackDialog(
  BuildContext context,
  AnimationControllerComponent animComp,
) {
  final nameController = TextEditingController();
  final frameCountController = TextEditingController(text: "1");
  bool isLooping = true;
  bool mustFinish = false;
  bool isDestroyAnimation = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'New Animation Track',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelatedTextField(
                onChanged: (value) {
                  
                },
                controller: nameController,
                borderColor: Colors.white,
                keyboardType: TextInputType.text,
                hintText: 'Track Name',
              ),
              const SizedBox(height: 12),
              PixelatedTextField(
                onChanged: (value) {
                  
                },
                controller: frameCountController,
                borderColor: Colors.white,
                keyboardType: TextInputType.number,
                hintText: 'Initial Frame Count',
              ),
              const SizedBox(height: 12),
              _buildCheckbox(
                label: 'Looping',
                value: isLooping,
                onChanged: (val) => setState(() => isLooping = val ?? true),
              ),
              _buildCheckbox(
                label: 'Must Finish Before Transition',
                value: mustFinish,
                onChanged: (val) => setState(() => mustFinish = val ?? false),
              ),
              _buildCheckbox(
                label: 'Destroy Animation',
                subtitle: 'Creates transitions from all other animations',
                value: isDestroyAnimation,
                onChanged: (val) =>
                    setState(() => isDestroyAnimation = val ?? false),
              ),
            ],
          ),
        ),
        actions: [
          PixelArtButton(
            fontsize: 12,
            callback: () => Navigator.of(context).pop(),
            text: 'Cancel',
          ),
          const SizedBox(width: 12),
          PixelArtButton(
            fontsize: 12,
            callback: () {
              final name = nameController.text.trim();
              final count =
                  int.tryParse(frameCountController.text.trim()) ?? 1;

              if (name.isEmpty ||
                  animComp.animationTracks.containsKey(name)) {
                Navigator.pop(context);
                return;
              }

              final newTrack = AnimationTrack(
                name,
                [],
                isLooping,
                mustFinish,
                isDestroyAnimationTrack: isDestroyAnimation,
              );

              for (int i = 0; i < count; i++) {
                newTrack.addFrame(KeyFrame(sketches: []));
              }

              animComp.animationTracks[name] = newTrack;
              animComp.setTrack(name);
              animComp.setFrame(0);

              if (isDestroyAnimation) {
                animComp.markAsDestroyAnimation(name);
              }

              Navigator.pop(context);
            },
            text: 'Add',
          ),
        ],
      );
    },
  );
}

Widget _buildCheckbox({
  required String label,
  String? subtitle,
  required bool value,
  required void Function(bool?) onChanged,
}) {
  return CheckboxListTile(
    title: Text(
      label,
      style: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 12,
        color: Colors.white,
      ),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 10,
              color: Colors.white70,
            ),
          )
        : null,
    value: value,
    onChanged: onChanged,
    activeColor: Colors.white,
    checkColor: Colors.black,
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
  );
}
}