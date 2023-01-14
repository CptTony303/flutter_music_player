import 'package:flutter/material.dart';
import 'package:warable_musicplayer/widgets/earable.dart';
import './widgets/musicPlayer.dart';
import './widgets/fileExplorer.dart';

void main() {
  runApp(MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  MusicPlayerApp({Key? key}) : super(key: key);
  final GlobalKey<MusicPlayerState> _musicPlayerState = GlobalKey<MusicPlayerState>();
  void skip_next(){
    _musicPlayerState.currentState?.nextSong();
  }
  void skip_previous(){
    _musicPlayerState.currentState?.previousSong();
  }
  void play_pause(){
    _musicPlayerState.currentState?.playPause();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            title: const Text('Music Player'),
          ),
          body: Column(
            children: [
              EarableControler(onNod: skip_next, onLeft: skip_previous, onRight: play_pause),
              Expanded(child: MusicPlayer(key: _musicPlayerState))
            ]
          )),
    );
  }
}
