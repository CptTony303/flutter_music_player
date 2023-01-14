
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class FileExplorer extends StatefulWidget{

  const FileExplorer({Key? key, required this.onSongUpdate}) : super(key: key);
  final void Function(String) onSongUpdate;
  @override
  State<StatefulWidget> createState() => FileExplorerState();
}
class FileExplorerState extends State<FileExplorer>{

  RegExp regExp =
  new RegExp("\.(mp3|3gp|mp4|m4a|aac|ts|amr|flac|mid|xmf|mkv|ogg|wav|ota|imy|mxmf|rtttl|rtx|opus)", caseSensitive: false);


  String pathToFolder = 'Sample music';
  List<String> listFiles = [];
  int counter = 0;
  //List<String>getSampleList(){
    //var assets = rootBundle.loadString('AssetManifest.json');
    //Map json = json.decode(assets);
    //List get = json.keys.where((element) => element.endsWith(".xml")).toList();
    //return get;
  //}
  Future selectFolder() async {
    // use if want to loop
    //audioPlayer.setReleaseMode(ReleaseMode.LOOP);

    //load audio from url
    //String url = 'https://filesamples.com/samples/audio/mp3/Symphony%20No.6%20(1st%20movement).mp3';
    //audioPlayer.setUrl(url);

    //File locally on device
    final folder = await FilePicker.platform.getDirectoryPath(/*initialDirectory: 'assets/music'*/);
    if (folder != null) {

      Directory dir = Directory(folder!);
      List<String> newListFiles = [];
      await dir.list().forEach((element) {
      debugPrint('dir contains: $element is audio? ${regExp.hasMatch('$element')}');
      // Only add in List if file in path is supported
      if (regExp.hasMatch('$element')) {
        newListFiles.add(element.path);
      }
    });
      debugPrint('List of filepaths follows');
    debugPrint(newListFiles.toString());
    setState(() {
        pathToFolder = folder!;
        counter = 0;
        listFiles = newListFiles;
      });
    widget.onSongUpdate(newListFiles[0]);
    }
    }
    void previousSong(){
      debugPrint('initiate previous song');
      int newCounter = counter -1;
      if(newCounter < 0){
        newCounter = 0;
      }
      widget.onSongUpdate(listFiles[newCounter]);
      setState(() {
        counter = newCounter;
      });
    }
    void nextSong(){
    debugPrint('initiate next song');
    int newCounter = counter +1;
    if(newCounter >= listFiles.length){
      newCounter = 0;
    }
    widget.onSongUpdate(listFiles[newCounter]);
    setState(() {
      counter = newCounter;
    });
    }

    @override
    Widget build(BuildContext context) =>
        Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                  radius: 20,
                  child: IconButton(
                    icon: Icon(
                        Icons.folder
                    ),
                    iconSize: 25,
                    onPressed: () async {
                      selectFolder();
                    },
                  ),
              ),
              const Text(
                'Folder: ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                pathToFolder,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        );
  }
