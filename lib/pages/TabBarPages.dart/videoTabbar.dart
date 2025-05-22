import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymshood/pages/fullScreenVideoPage.dart';
import 'package:gymshood/sevices/fileserver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTabBar extends StatefulWidget {
  const VideoTabBar({super.key});

  @override
  State<VideoTabBar> createState() => _VideoTabBarState();
}

class _VideoTabBarState extends State<VideoTabBar> {
  List<String> _videoUrls = [];
  final Map<String, String> _thumbnails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideosAndThumbnails();
  }

  Future<void> _loadVideosAndThumbnails() async {
    final urls = await Fileserver().fetchMediaUrls('video');
    _videoUrls=urls;
    final Map<String, String> thumbnails = {};
    for (var url in urls) {
      developer.log(url);
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );
      if (thumbPath != null) {
        thumbnails[url] = thumbPath;
      }
    }

    setState(() {
      _videoUrls = urls;
      _thumbnails.addAll(thumbnails);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadVideosAndThumbnails,
      child: GridView.count(
        crossAxisCount: 2,
        children: _videoUrls.map((url) {
          final thumbPath = _thumbnails[url];
          developer.log('Video Url Here : $url');
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenVideoPlayer(videoUrl: url),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                thumbPath != null
                    ? Image.file(File(thumbPath), fit: BoxFit.cover, width: double.infinity)
                    : Container(
                        color: Colors.black12,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
