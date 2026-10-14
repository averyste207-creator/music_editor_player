import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/playlist.dart';

class PlaylistStorage {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/playlists.json');
  }

  static Future<List<Playlist>> loadPlaylists() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => Playlist.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading playlists: $e');
      return [];
    }
  }

  static Future<void> savePlaylists(List<Playlist> playlists) async {
    try {
      final file = await _getFile();
      final jsonList = playlists.map((p) => p.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Error saving playlists: $e');
    }
  }
}