
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationTrackControlPanel extends StatelessWidget {
  const AnimationTrackControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(
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
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Dropdown to switch tracks
                 Padding(
                   padding: EdgeInsets.symmetric(horizontal: 10),
                   child: DropdownButton<String>(
                     value: currentTrack.name,
                     items: trackNames.map((name) {
                       return DropdownMenuItem(
                         value: name,
                         child: Text(name),
                       );
                     }).toList(),
                     onChanged: (selected) {
                       if (selected == null || selected == currentTrack.name) return;
                       final newTrack = animComp.animationTracks[selected]!;
                                 
                       // Clamp frame index
                       if (animComp.currentFrame >= newTrack.frames.length) {
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
                           style: Theme.of(context).textTheme.titleMedium),
                       IconButton(
                         onPressed: () {
                           if (animComp.animationTracks.length <= 1) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                               content: Text("At least one animation track must exist."),
                             ));
                             return;
                           }
                                 
                           final currentName = currentTrack.name;
                           animComp.animationTracks.remove(currentName);
                                 
                           // Fallback
                           final fallback = animComp.animationTracks.keys.first;
                           animComp.setTrack(fallback);
                           animComp.setFrame(0);
                         },
                         icon: const Icon(Icons.delete, color: Colors.red),
                       ),
                     ],
                   ),
                 ),
             
                 const Divider(),
             
                 // Checkboxes for looping and mustFinish
                 ChangeNotifierProvider.value(
                   value: currentTrack,
                   child: Consumer<AnimationTrack>(
                     builder: (context, currentTrack, child) =>  CheckboxListTile(
                       title: const Text("Looping"),
                       value: currentTrack.isLooping,
                       onChanged: (value) {
                         currentTrack.setIsLooping(value ?? false);
                         
                       },
                     ),
                   ),
                 ),
                 ChangeNotifierProvider.value(
                   value: currentTrack,
                 
                   child: Consumer<AnimationTrack>(
                     
                     builder: (context, currentTrack, child) =>  CheckboxListTile(
                       title: const Text("Must Finish Before Transition"),
                       value: currentTrack.mustFinish,
                       onChanged: (value) {
                         currentTrack.setMustFinish(value ?? false);
                         
                       },
                     ),
                   ),
                 ),
             
                 const Divider(),
             
                 // Add new track
                 Center(
                   child: IconButton(
                     icon: const Icon(Icons.add_circle_outline),
                     tooltip: "Add Animation Track",
                     onPressed: () {
                       showDialog(
                         context: context,
                         builder: (context) => _buildAddTrackDialog(context, animComp),
                       );
                     },
                   ),
                 ),
               ],
             );
                }),
        );
      },
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

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("New Animation Track"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Track Name"),
              ),
              TextField(
                controller: frameCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Initial Frame Count"),
              ),
              CheckboxListTile(
                title: const Text("Looping"),
                value: isLooping,
                onChanged: (val) => setState(() => isLooping = val ?? true),
              ),
              CheckboxListTile(
                title: const Text("Must Finish Before Transition"),
                value: mustFinish,
                onChanged: (val) => setState(() => mustFinish = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final count = int.tryParse(frameCountController.text.trim()) ?? 1;

                if (name.isEmpty || animComp.animationTracks.containsKey(name)) {
                  Navigator.pop(context);
                  return;
                }

                final newTrack = AnimationTrack(name, [], isLooping, mustFinish);
                for (int i = 0; i < count; i++) {
                  newTrack.addFrame(KeyFrame(sketches: []));
                }

                animComp.animationTracks[name] = newTrack;
                animComp.setTrack(name);
                animComp.setFrame(0);

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
