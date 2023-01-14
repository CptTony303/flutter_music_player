import 'package:flutter/material.dart';
import './widgets/musicPlayer.dart';
import './widgets/fileExplorer.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({Key? key}) : super(key: key);
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
              //FileExplorer(),
              Expanded(child: MusicPlayer())
            ]
          )),
    );
  }
}
