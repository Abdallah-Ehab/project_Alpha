import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit() : super(StorageInitial());

  final supabase = Supabase.instance.client;

  Future<void> uploadCurrentJson() async {
    final filename= await readCurrentProject();
    if (filename == null) {
      log("No current project file found");
      emit(StorageError("No current project file found"));
      return;
    }
    final uid = supabase.auth.currentUser!.id;
    final projectJson = EntityManager().toJson();
    final jsonString = jsonEncode(projectJson);

    final bytes = utf8.encode(jsonString);
    final filePath = '$uid/$filename.json';

    await supabase.storage.from('userstorage').uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(contentType: 'application/json',upsert: true),

    );
    emit(StorageSuccess("File uploaded"));
  }

  Future<String?> readCurrentProject() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/current.json');
      log(file.toString());
      log(file.exists().toString());
      if (!await file.exists()) return null;

      final jsonStr = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return data['project'] as String?;
    } catch (e) {

      log('Error reading current project: $e');
      return null;
    }
  }

  Future<bool> downloadJson(String filename) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final dir = await getApplicationDocumentsDirectory();
    final localFile = File('${dir.path}/$uid/$filename.json');
    try {
      if (uid == null) throw Exception('Not authenticated');
      log('Attempting to download $uid/$filename.json from Supabase');
      final bytes = await Supabase.instance.client
          .storage
          .from('userstorage')
          .download('$uid/$filename.json');
      final jsonString = utf8.decode(bytes);
      if (jsonString.isEmpty) {
        log('Downloaded file is empty');
        return false;
      }
      await localFile.writeAsString(jsonString);
      log('✅ File downloaded to ${localFile.path}');
      return true;
    } on StorageException catch (e) {
      log('❌ Storage error (${e.statusCode}): ${e.message}');
      if (await localFile.exists()) {
        await localFile.delete();
        log('🗑️ Deleted stale file ${localFile.path}');
      }
      return false;
    } catch (e, st) {
      log('❌ Unexpected error: $e\n$st');
      return false;
    }
  }


  Future<void> deleteProject(String filename) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        emit(StorageError('User not authenticated'));
        return;
      }

      final filePath = '$uid/$filename.json';

      // Delete from Supabase
      await supabase.storage.from('userstorage').remove([filePath]);

      // Delete locally
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/$uid/$filename.json');
      if (await localFile.exists()) {
        await localFile.delete();
      }

      emit(StorageSuccess('Project deleted successfully'));
    } catch (e, st) {
      log('❌ Failed to delete project: $e\n$st');
      emit(StorageError('Failed to delete project'));
    }
  }





}