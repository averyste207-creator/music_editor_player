import 'package:flutter/material.dart';
import 'models/playlist.dart';
import 'screens/playlist_details_screen.dart';
import 'services/playlist_storage.dart';

void main() {
  runApp(const PlaylistOrganizerApp());
}

class PlaylistOrganizerApp extends StatelessWidget {
  const PlaylistOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playlist Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await PlaylistStorage.loadPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  Future<void> _savePlaylists() async {
    await PlaylistStorage.savePlaylists(_playlists);
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Playlist name',
              hintText: 'e.g. Chill Vibes, Workout, Study',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                setState(() {
                  _playlists.add(
                    Playlist(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      createdAt: DateTime.now(),
                    ),
                  );
                });

                await _savePlaylists();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
              ? const Center(
                  child: Text(
                    'No playlists yet.\nTap + to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(playlist.name),
                        subtitle: Text(
                          'Created ${_formatDate(playlist.createdAt)} • ${playlist.songs.length} songs',
                        ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              final nameController = TextEditingController(text: playlist.name);
                  
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Rename Playlist'),
                                    content: TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(labelText: 'Playlist name'),
                                      autofocus: true,
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          final newName = nameController.text.trim();
                                          if (newName.isEmpty) return;
                  
                                          setState(() {
                                            _playlists[index] = Playlist(
                                              id: playlist.id,
                                              name: newName,
                                              createdAt: playlist.createdAt,
                                              songs: playlist.songs,
                                            );
                                          });
                  
                                          await _savePlaylists();
                                          if (mounted) Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Playlist?'),
                                  content: Text('Are you sure you want to delete "${playlist.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                  
                              if (confirm == true) {
                                setState(() {
                                  _playlists.removeAt(index);
                                });
                                await _savePlaylists();
                              }
                            },
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistDetailScreen(playlist: playlist),
                          ),
                        );
                        await _loadPlaylists();
                      },
                    ),
                  );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}