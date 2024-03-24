// This is a separate widget for a single media item
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/media/audio_player_widget.dart';
import 'package:flutter_application_1/media/video_player_widget.dart';
import 'package:photo_view/photo_view.dart';

class MediaItem extends StatelessWidget {
  final DocumentSnapshot mediaDoc;
  //final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MediaItem({
    Key? key,
    required this.mediaDoc,
    //required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  void _showVideoFullScreen(BuildContext context, String mediaUrl){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: VideoPlayerWidget(mediaUrl: mediaUrl),
          ),
        ),
        ),
    );
  }

  void _handleMediaTap(BuildContext context, String mediaType, String mediaUrl){
    switch (mediaType) {
      case 'video':
        _showFullScreenWidget(context, VideoPlayerWidget(mediaUrl: mediaUrl));
        break;
      case 'audio':
        _showFullScreenWidget(context, AudioPlayerWidget(mediaUrl: mediaUrl));
        break;
      case 'image':
        _showFullScreenWidget(
          context, 
          PhotoView(
            imageProvider: NetworkImage(mediaUrl),
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
          ),
          );
        break;

      default:
    }
  }

  void _showFullScreenWidget(BuildContext context, Widget child){
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context)=> Scaffold(
          appBar: AppBar(),
          body: Center(child: child),
        )
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    // Assume the media document contains a field 'url' for the media URL
    final String mediaUrl = mediaDoc['url'];
    final String mediaType = mediaDoc['type'];

    Widget childMedia;

    switch (mediaType) {
      case 'image':
        childMedia = Image.network(mediaUrl, fit: BoxFit.cover);
        break;
      case 'video':
        childMedia = VideoPlayerWidget(mediaUrl: mediaUrl);
        break;
      case 'audio':
        childMedia = AudioPlayerWidget(mediaUrl: mediaUrl);
      default:
      throw 'unknown media type: $mediaType';
    }
    return GridTile(
      footer: GridTileBar(
        backgroundColor: Colors.black,

        leading: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
      child: GestureDetector(
        onTap: () =>
        _handleMediaTap(context, mediaType, mediaUrl),
        
          // Handle media item tap, e.g., open in full screen or play video
        child: childMedia,
      ),
    );
  }
}