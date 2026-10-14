import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_storage.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  late List<Song> _songs;
  String _searchQuery = '';

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
                final navigator = Navigator.of(context);
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
                if (mounted) navigator.pop();
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
                final navigator = Navigator.of(context);
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
                if (mounted) navigator.pop();
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

  List<Song> get _filteredSongs {
    if (_searchQuery.trim().isEmpty) {
      return _songs;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSongItem(Song song, int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _songs.isEmpty
          ? const Center(
              child: Text(
                'No songs yet.\nTap + to add a song!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : _searchQuery.trim().isEmpty
          ? ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;
                setState(() {
                  final song = _songs.removeAt(oldIndex);
                  _songs.insert(newIndex, song);
                });
                await _saveChanges();
              },
              padding: const EdgeInsets.all(12),
              itemCount: _songs.length,
              itemBuilder: (context, index) =>
                  _buildSongItem(_songs[index], index),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                final songIndex = _songs.indexOf(song);
                return _buildSongItem(song, songIndex);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
