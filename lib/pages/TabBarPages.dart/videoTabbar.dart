import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/addGymMediaPage.dart';
import 'package:gymshood/pages/fullScreenVideoPage.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTabBar extends StatefulWidget {
  final Gym gym;
  const VideoTabBar({super.key, required this.gym});

  @override
  State<VideoTabBar> createState() => _VideoTabBarState();
}

class _VideoTabBarState extends State<VideoTabBar> {
  List<String> _videoUrls = [];
  final Map<String, String> _thumbnails = {};
  bool _isLoading = true;
  late Future<void> _futurefiles;
  bool _selectionMode = false;
  Set<String> _selectedVideos = {};

  @override
  void initState() {
    super.initState();
    _futurefiles = _loadVideosAndThumbnails();
  }

  Future<void> refreshVideos() async {
    setState(() {
      _futurefiles = _loadVideosAndThumbnails();
    });
  }

  Future<void> _loadVideosAndThumbnails() async {
    final urls = await Fileserver().fetchMediaUrls('video' , widget.gym.gymid);
    _videoUrls = urls;
    final Map<String, String> thumbnails = {};
    for (var url in urls) {
      final tempDir = await getTemporaryDirectory();
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final tempVideo = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
      await tempVideo.writeAsBytes(bytes);
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
      _thumbnails.clear();
      _thumbnails.addAll(thumbnails);
      _isLoading = false;
      _selectionMode = false;
      _selectedVideos.clear();
    });
  }

  Future<void> _deleteSelectedVideos() async {
    final confirmed = await showDeleteDialog(context);
    if (!confirmed) return;

    for (var url in _selectedVideos) {
      final filename = url.split('/').last;
      await Fileserver().deleteFileFromServer(filename);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${_selectedVideos.length} videos')),
    );

    refreshVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:_selectionMode? AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(_selectionMode
            ? "${_selectedVideos.length} selected"
            : "Videos" , style: TextStyle(color: Colors.white),),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete , color: Colors.white,),
                  onPressed: _deleteSelectedVideos,
                )
              ]
            : [],
      ):null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVideosAndThumbnails,
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              child: _videoUrls.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_collection_sharp,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text("No videos Available",
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => UploadMultipleImagesPage(gym: widget.gym,)),
                              );
                              refreshVideos();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("add video"),
                          )
                        ],
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      children: _videoUrls.map((url) {
                        final thumbPath = _thumbnails[url];
                        final isSelected = _selectedVideos.contains(url);
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _selectionMode = true;
                              _selectedVideos.add(url);
                            });
                          },
                          onTap: () {
                            if (_selectionMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedVideos.remove(url);
                                  if (_selectedVideos.isEmpty) {
                                    _selectionMode = false;
                                  }
                                } else {
                                  _selectedVideos.add(url);
                                }
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenVideoPlayer(videoUrl: url),
                                ),
                              );
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              thumbPath != null
                                  ? Image.file(File(thumbPath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity)
                                  : Container(
                                      color: Colors.black12,
                                      child:
                                          const Center(child: CircularProgressIndicator()),
                                    ),
                              if (!_selectionMode)
                                const Icon(Icons.play_circle_fill,
                                    size: 48, color: Colors.white),
                              if (_selectionMode && isSelected)
                                Container(
                                  color: Colors.black45,
                                  child: const Icon(Icons.check_circle,
                                      color: Colors.white, size: 40),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
    );
  }
}
