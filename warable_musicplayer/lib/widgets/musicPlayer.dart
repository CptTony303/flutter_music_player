import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:warable_musicplayer/widgets/fileExplorer.dart';


class MusicPlayer extends StatefulWidget{
  const MusicPlayer({Key? key}) : super(key: key);
  @override
  State<MusicPlayer> createState() => MusicPlayerState();
}
class MusicPlayerState extends State<MusicPlayer>{

  final GlobalKey<FileExplorerState> _fileExplorerState = GlobalKey<FileExplorerState>();
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  void playPause(){
    if(isPlaying){
      audioPlayer.pause();
    }else{
      //String url = 'https://filesamples.com/samples/audio/mp3/Symphony%20No.6%20(1st%20movement).mp3';
      //'https://cpttony303.github.io/music/gamedrix974/39.wav';
      //await audioPlayer.play(url);
      audioPlayer.resume();
    }
  }
  void previousSong(){
    _fileExplorerState.currentState?.previousSong();
    audioPlayer.resume();
  }
  void nextSong(){
    _fileExplorerState.currentState?.nextSong();
    audioPlayer.resume();
  }
  Future setAudio(String pathToFile) async {
    // use if want to loop
    //audioPlayer.setReleaseMode(ReleaseMode.LOOP);

    //load audio from url
    //String url = 'https://filesamples.com/samples/audio/mp3/Symphony%20No.6%20(1st%20movement).mp3';
    //audioPlayer.setUrl(url);

    //File locally on device
    position = Duration.zero;
    audioPlayer.setUrl(pathToFile, isLocal: true);
    audioPlayer.seek(position);
  }

  @override void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //fileExplorer.onNewFile.listen((){})
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      debugPrint('Song completed');
      nextSong();
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState((){
        position = newPosition;
      });
    });
  }
  String formatTime(Duration dur){
    String twoDigits(int n) =>  n.toString().padLeft(2, '0');
    final hours = twoDigits(dur.inHours);
    final minutes = twoDigits(dur.inMinutes.remainder(60));
    final seconds = twoDigits(dur.inSeconds.remainder(60));
    return [
      if(dur.inHours > 0) hours,
      minutes,
      seconds
    ].join(':');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/AudioPlayerDefault.jpg',
            width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            )
          ),
          const SizedBox(height: 5),
          const Text(
            'Song',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Interpret',
            style: TextStyle(fontSize: 20),
          ),
          Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);
            },
          ),
          Padding(
                padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    Text(formatTime(duration)),
                  ],
                ),
              ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children:[
              CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    icon: Icon(
                        Icons.skip_previous
                    ),
                    iconSize: 50,
                    onPressed: () async {
                      previousSong();
                    },
                  )
              ),
              const SizedBox(width: 10),
              CircleAvatar(
            radius: 35,
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause: Icons.play_arrow
              ),
              iconSize: 50,
              onPressed: () async {
                playPause();
              },
            )
          ),
              const SizedBox(width: 10),
              CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    icon: Icon(
                        Icons.skip_next
                    ),
                    iconSize: 50,
                    onPressed: () async {
                      nextSong();
                    },
                  )
              ),
            ]),
          const SizedBox(height: 10),
          Expanded(child: FileExplorer(key: _fileExplorerState,onSongUpdate: setAudio)),
        ],
      ),
  );
}