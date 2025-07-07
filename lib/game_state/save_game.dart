import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

Future<void> saveGame() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/save.json';
  log('Saving game to $path');
  final jsonData = EntityManager().toJson();
  log(jsonData.toString());
  final file = File(path);
  await file.writeAsString(jsonEncode(jsonData));
}

class SaveGameButton extends StatelessWidget {
  const SaveGameButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PixelArtButton(
      text: 'Save Game',
      fontsize: 12,
      callback: () {
        _showSavingDialog(context);
      },
    );
  }

  void _showSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _startSaving(context); // triggers save after dialog is shown
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Saving game...',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startSaving(BuildContext context) async {
    try {
      await saveGame();
      Navigator.of(context).pop(); // close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Game saved successfully!',
            style: TextStyle(fontFamily: 'PressStart2P'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Failed to save game: $e');
      Navigator.of(context).pop(); // close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save game: $e',
            style: const TextStyle(fontFamily: 'PressStart2P'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
