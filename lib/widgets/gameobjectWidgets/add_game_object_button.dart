import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class AddGameObjectButton extends StatefulWidget {
  const AddGameObjectButton({super.key});

  @override
  State<AddGameObjectButton> createState() => _AddGameObjectButtonState();
}

class _AddGameObjectButtonState extends State<AddGameObjectButton> {
  late TextEditingController _gameObjectNameController;
  @override
  void initState() {
   _gameObjectNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _gameObjectNameController.dispose();
      super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    return  IconButton(
      onPressed: (){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: TextField(
              controller: _gameObjectNameController,
              decoration: const InputDecoration(
                hintText: "enter the gameObject name"
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                gameObjectProvider.createNewGameObject(_gameObjectNameController.text);
                Navigator.of(context).pop();
              }, child: const Text("apply")),
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              },child: const Text("cancel"),)
            ],
          );
        });
        
      },
      icon: const Icon(Icons.add_circle,size: 20,color: Colors.black),
    );
  }
}