import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scratch_clone/game_scene/test_game_loop.dart';
import 'package:scratch_clone/game_state/load_game_page.dart';
import 'package:scratch_clone/login_and_signup/presentation/cubit/storage_cubit.dart';
import 'package:scratch_clone/login_and_signup/presentation/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/ui_widgets/pixelated_buttons.dart';
import '../../core/ui_widgets/pixelated_text_feild.dart';

class LoadProjectScreen extends StatefulWidget {
  const LoadProjectScreen({super.key});

  @override
  State<LoadProjectScreen> createState() => _LoadProjectScreenState();
}

class _LoadProjectScreenState extends State<LoadProjectScreen> {
  Map<String, dynamic> projects = {};
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final TextEditingController _projectNameController = TextEditingController();

  Future<void> writeJsonFile(String fileName, String content) async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser!.id;
    final dir = await getApplicationDocumentsDirectory();
    final userDir = Directory('${dir.path}/$uid');

    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    final file = File('${userDir.path}/$fileName.json');
    final data = {
      "createdAt": DateTime.now().toIso8601String(),
      "data": content,
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> writeCurrentProject(String projectName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/current.json');

    final data = {
      'project': projectName,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  Future<void> loadProjects() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser!.id;
    final dir = await getApplicationDocumentsDirectory();
    final userDir = Directory('${dir.path}/$uid');

    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    // Load local files
    final files = userDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));

    final Map<String, dynamic> loaded = {};
    for (final file in files) {
      final fileName = file.uri.pathSegments.last.replaceAll('.json', '');
      try {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        loaded[fileName] = decoded;
      } catch (e) {
        log("load projects from error: $e");
      }
    }

    // Load cloud file names
    try {
      final response =
          await supabase.storage.from('userstorage').list(path: uid);
      log('Raw response: $response'); // Log to inspect FileObject list

      // Extract names from FileObject list
      final fileNames = response
          .map((fileObject) => fileObject.name)
          .where((name) =>
              name.endsWith('.json')) // Optional: filter for .json files
          .toList();
      log('Cloud file names: $fileNames');

      // Optionally, download cloud files to include in projects
      for (final fileName in fileNames) {
        try {
          final fileContent = await supabase.storage
              .from('userstorage')
              .download('$uid/$fileName');
          final decoded = jsonDecode(utf8.decode(fileContent));
          loaded[fileName.replaceAll('.json', '')] = decoded;
        } catch (e) {
          log('Error downloading file $fileName: $e');
        }
      }
    } catch (e) {
      log('Supabase list error: $e');
    }
    if (!mounted) return;
    setState(() {
      projects = loaded;
    });
  }

  void _submit() async {
    final name = _projectNameController.text.trim();
    if (name.isNotEmpty) {
      await writeJsonFile(name, "");
      _projectNameController.clear();
      Navigator.of(context).pop();
      await loadProjects();
    }
  }

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'Create New Project',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            PixelatedTextField(
              maxLength: 100,
              borderColor: Colors.white,
              keyboardType: TextInputType.text,
              onChanged: (v) {},
              hintText: 'Project Name',
              controller: _projectNameController,
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          PixelArtButton(
            fontsize: 12,
            callback: () => Navigator.of(context).pop(),
            text: 'Cancel',
          ),
          PixelArtButton(
            fontsize: 12,
            callback: _submit,
            text: 'Create',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectNames = projects.keys.toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: _showCreateProjectDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Alpha",
                  style: TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Your Projects",
                style: TextStyle(
                  fontFamily: "PressStart2P",
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: projectNames.length,
                  itemBuilder: (context, index) {
                    if (projectNames[index] == "current") {
                      return SizedBox.shrink();
                    } else {
                      final name = projectNames[index];
                      final meta = projects[name] as Map<String, dynamic>;
                      final createdAt =
                          DateTime.tryParse(meta['createdAt'] ?? '') ??
                              DateTime.now();
                      return Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "PressStart2P",
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Text(
                            "Created: ${dateFormatter.format(createdAt)}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 8,
                              fontFamily: "PressStart2P",
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: Text(
                                          "Delete project '$name' from device and cloud?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await context
                                        .read<StorageCubit>()
                                        .deleteProject(name);
                                    await loadProjects(); // refresh UI after deletion
                                  }
                                },
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white38, size: 16),
                            ],
                          ),
                          onTap: () async {
                            await writeCurrentProject(name);
                            await context
                                .read<StorageCubit>()
                                .downloadJson(name);

                            final supabase = Supabase.instance.client;
                            final uid = supabase.auth.currentUser!.id;
                            final dir =
                                await getApplicationDocumentsDirectory();
                            final file = File('${dir.path}/$uid/$name.json');
                            final exists = await file.exists();

                            final isNonEmpty =
                                exists && await file.length() > 0;

                            if (isNonEmpty) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GameLoaderPage(filename: name),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TestGameLoop(), // Add filename if needed
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
