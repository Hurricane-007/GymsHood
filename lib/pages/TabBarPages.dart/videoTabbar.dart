import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/createServicesPages/addGymMediaPage.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/fullScreenVideoPage.dart';
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
  bool _selectionMode = false;
  Set<String> _selectedVideos = {};

  bool _isVideoFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ext == 'mov' || ext == 'mp4';
  }

  @override
  void initState() {
    super.initState();
    _loadVideosAndThumbnails();
  }

  Future<void> refreshVideos() async {
    setState(() {
      _loadVideosAndThumbnails();
    });
  }

  Future<void> _loadVideosAndThumbnails() async {
    setState(() {
      _isLoading = true;
      _videoUrls = (widget.gym.media?.mediaUrls ?? [])
          .where((url) => _isVideoFile(url))
          .toList();
    });

    final Map<String, String> thumbnails = {};
    for (var url in _videoUrls) {
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
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _videoUrls.length,
                      itemBuilder: (context, index) {
                        final url = _videoUrls[index];
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
                      },
                    ),
            ),
    );
  }
}
