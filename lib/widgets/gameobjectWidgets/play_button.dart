import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';


class PlayButton extends StatelessWidget {
  const PlayButton({super.key});
  
  @override
  Widget build(BuildContext context) {

    
    return IconButton(
      onPressed: (){
        onPlay(context);
      },
      icon: const Icon(Icons.play_arrow_rounded),
    );
  }


  void onPlay(BuildContext context){
    var gameObjectManagerProvider = Provider.of<GameObjectManagerProvider>(context,listen:false);
    var gameObejcts = gameObjectManagerProvider.gameObjects.values;

    for(var gameObject in gameObejcts){
      gameObject.execute(gameObjectManagerProvider);
    }
  }
}