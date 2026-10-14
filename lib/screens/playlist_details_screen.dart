import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_storage.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List<Song> _songs;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.playlist.songs);
  }

  Future<void> _saveChanges() async {
    widget.playlist.songs
      ..clear()
      ..addAll(_songs);

    final allPlaylists = await PlaylistStorage.loadPlaylists();
    final index = allPlaylists.indexWhere((p) => p.id == widget.playlist.id);
    if (index != -1) {
      allPlaylists[index] = widget.playlist;
      await PlaylistStorage.savePlaylists(allPlaylists);
    }
  }

  void _showAddSongDialog() {
    final titleController = TextEditingController();
    final artistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Song title',
                  hintText: 'e.g. Bohemian Rhapsody',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  hintText: 'e.g. Queen',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final artist = artistController.text.trim();

                if (title.isEmpty) return;

                setState(() {
                  _songs.add(
                    Song(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      artist: artist.isEmpty ? 'Unknown Artist' : artist,
                    ),
                  );
                });

                await _saveChanges();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSongDialog(Song song, int index) {
    final titleController = TextEditingController(text: song.title);
    final artistController = TextEditingController(text: song.artist);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Song title'),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final artist = artistController.text.trim();

                if (title.isEmpty) return;

                setState(() {
                  _songs[index] = Song(
                    id: song.id,
                    title: title,
                    artist: artist.isEmpty ? 'Unknown Artist' : artist,
                  );
                });

                await _saveChanges();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSong(int index) async {
    setState(() {
      _songs.removeAt(index);
    });
    await _saveChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: _songs.isEmpty
          ? const Center(
              child: Text(
                'No songs yet.\nTap + to add a song!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return Dismissible(
                  key: Key(song.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteSong(index),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEditSongDialog(song, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteSong(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}