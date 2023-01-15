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
    print('right');
    _musicPlayerState.currentState?.nextSong();
  }
  void skip_previous(){
    print('left');
    _musicPlayerState.currentState?.previousSong();
  }
  void play_pause(){
    print('nodded');
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
              EarableControler(onNod: play_pause, onLeft: skip_previous, onRight:skip_next ),
              Expanded(child: MusicPlayer(key: _musicPlayerState))
            ]
          )),
    );
  }
}
