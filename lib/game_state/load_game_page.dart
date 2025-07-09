import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_scene/game_view.dart';
import 'package:scratch_clone/game_scene/test_game_loop.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class GameLoaderPage extends StatefulWidget {
  final String filename;
  const GameLoaderPage({super.key, required this.filename});

  @override
  State<GameLoaderPage> createState() => _GameLoaderPageState();
}

class _GameLoaderPageState extends State<GameLoaderPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      final entityManager = context.read<EntityManager>();

      final String gameJsonString = await _loadGameJsonFromFile(widget.filename);
      final Map<String, dynamic> gameJson = jsonDecode(gameJsonString);

      entityManager.fromJson(gameJson);
      await _restoreAnimationImages(entityManager);

      // Go to game view
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TestGameLoop()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load game: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreAnimationImages(EntityManager entityManager) async {
    List<Future<void>> tasks = [];

    for (final entityMap in entityManager.entities.values) {
      for (final entity in entityMap.values) {
        final animationComponent = entity.getComponent<AnimationControllerComponent>();
        if (animationComponent == null) continue;

        for (final track in animationComponent.animationTracks.values) {
          for (final frame in track.frames) {
            if (frame.imageBase64 != null && frame.image == null) {
              tasks.add(() async {
                try {
                  frame.image = await base64ToImage(frame.imageBase64!);
                } catch (e) {
                  debugPrint('Image decode failed for frame: $e');
                }
              }());
            }
          }
        }
      }
    }

    await Future.wait(tasks);
  }

  Future<ui.Image> base64ToImage(String base64Str) async {
    final Uint8List bytes = base64Decode(base64Str);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }



Future<String> _loadGameJsonFromFile(String filename) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$uid/$filename.json';
  final file = File(path);

  if (!await file.exists()) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TestGameLoop()),
    );
    return Future.error('Game JSON not found');
  }
  String fileContent = await file.readAsString();
  log('file content: $fileContent');
  return fileContent;
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Text(_errorMessage ?? 'Unexpected error'),
      ),
    );
  }
}