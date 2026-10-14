import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    List<Song>? songs,
  }) : songs = songs ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      songs: (json['songs'] as List<dynamic>)
          .map((s) => Song.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}