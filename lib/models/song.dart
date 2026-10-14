class Song {
  final String id;
  final String title;
  final String artist;

  Song({
    required this.id,
    required this.title,
    required this.artist,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
    );
  }
}