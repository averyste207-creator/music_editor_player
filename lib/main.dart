import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'No playlists yet.\nTap + to create one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We'll add create playlist here in the next step
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}