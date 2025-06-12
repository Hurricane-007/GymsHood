import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
  super.initState();
  _prepareAndPlayVideo();
}

Future<void> _prepareAndPlayVideo() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final videoFileName = widget.videoUrl.split('/').last;
    final videoFilePath = "${tempDir.path}/$videoFileName";
    final videoFile = File(videoFilePath);

    if (!await videoFile.exists()) {
      developer.log("Downloading video: ${widget.videoUrl}");
      final response = await http.get(Uri.parse(widget.videoUrl));
      if (response.statusCode == 200) {
        await videoFile.writeAsBytes(response.bodyBytes);
        developer.log("Video downloaded to: $videoFilePath");
      } else {
        developer.log("Failed to download video: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download video')),
        );
        return;
      }
    } else {
      developer.log("Video already downloaded: $videoFilePath");
    }

    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      });
  } catch (e) {
    developer.log('Error while loading video: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error loading video')),
    );
  }
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
          mediaType: 'video',
          mediaUrl: mediaUrlsupdated,
          logourl: widget.gym.media!.logoUrl,
          gymId: widget.gym.gymid);
      if (success == 'Media updated successfully') {
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
