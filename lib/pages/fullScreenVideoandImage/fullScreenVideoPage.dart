import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:video_player/video_player.dart';
import 'package:gymshood/services/fileserver.dart'; // Import your delete function

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Gym gym;
  const FullScreenVideoPlayer(
      {super.key, required this.videoUrl, required this.gym});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    developer.log(widget.videoUrl);
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteVideo() async {
    final confirm = await showDeleteDialog(context);

    if (confirm == true) {
      List<String> mediaUrlsupdated = widget.gym.media!.mediaUrls;
      mediaUrlsupdated.remove(widget.videoUrl);
      final success = await Gymserviceprovider.server().addGymMedia(
          mediaType: 'photo',
          mediaUrl: mediaUrlsupdated,
          logourl: widget.gym.media!.logoUrl,
          gymId: widget.gym.gymid);
      if (success == 'Successfully added Media') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteVideo,
          ),
        ],
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _isInitialized
          ? Padding(
              padding: EdgeInsets.only(right: mq.width * 0.38),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            )
          : null,
    );
  }
}
