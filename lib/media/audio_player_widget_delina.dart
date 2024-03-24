import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget{
  final String mediaUrl;

  const AudioPlayerWidget({
    Key ? key, required this.mediaUrl 
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>{
  late AudioPlayer _player;

  @override
  void initState(){
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.mediaUrl);
  }

  @override
  Widget build(BuildContext context){
    return IconButton(
      onPressed: ()=> _player.play(), 
      icon: const Icon(Icons.play_arrow),
      );
  }

  @override
  void dispose(){
    _player.dispose();
    super.dispose();
  }

}