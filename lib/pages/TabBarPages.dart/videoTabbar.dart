import 'dart:developer' as developer;
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/createServicesPages/addGymMediaPage.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/fullScreenVideoPage.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:http/http.dart' as http;
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
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        developer.log("Invalid URL format: $url");
        return false;
      }
      final ext = url.toLowerCase().split('.').last;
      return ext == 'mov' || ext == 'mp4';
    } catch (e) {
      developer.log("Error parsing URL $url: $e");
      return false;
    }
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
  try {
    setState(() {
      _isLoading = true;
      _videoUrls = (widget.gym.media?.mediaUrls ?? [])
          .where((url) => _isVideoFile(url))
          .toList();
    });

    final Map<String, String> thumbnails = {};
    final tempDir = await getTemporaryDirectory();

    for (var url in _videoUrls) {
      try {
        developer.log("Downloading video for thumbnail: $url");

        // Download the video file to a local temp file
        final videoFileName = url.split('/').last;
        final videoFilePath = "${tempDir.path}/$videoFileName";
        final videoFile = File(videoFilePath);

        // Only download if not already downloaded
        if (!await videoFile.exists()) {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            await videoFile.writeAsBytes(response.bodyBytes);
          } else {
            developer.log("Failed to download video: ${response.statusCode}");
            continue;
          }
        }

        // Generate thumbnail from the downloaded local file
        final thumbPath = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 75,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            developer.log("Thumbnail generation timed out for: $url");
            return null;
          },
        );

        developer.log("Thumbnail path: ${thumbPath ?? "no path"}");

        if (thumbPath != null) {
          thumbnails[url] = thumbPath;
          developer.log("Successfully generated thumbnail for: $url");
        } else {
          developer.log("Failed to generate thumbnail for: $url");
        }
      } catch (e) {
        developer.log("Error processing video $url: $e");
      }
    }

    setState(() {
      _thumbnails.clear();
      _thumbnails.addAll(thumbnails);
      _isLoading = false;
      _selectionMode = false;
      _selectedVideos.clear();
    });
  } catch (e) {
    developer.log("Error in _loadVideosAndThumbnails: $e");
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _deleteSelectedVideos() async {
    final confirmed = await showDeleteDialog(context);
    if (!confirmed) return;
        List<String> mediaUrls;
    mediaUrls = widget.gym.media!.mediaUrls;
    // mediaUrls = [];
    for (var url in _selectedVideos) {
     mediaUrls.remove(url);
    }
     await Gymserviceprovider.server().addGymMedia(
      mediaType: 'video',
      mediaUrl: mediaUrls,
      logourl: widget.gym.media!.logoUrl,
      gymId: widget.gym.gymid
    );
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
                                  builder: (_) => FullScreenVideoPlayer(videoUrl: url , gym: widget.gym,),
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

            floatingActionButton: _selectionMode
          ? FloatingActionButton(
              onPressed: _deleteSelectedVideos,
              child: Icon(Icons.delete),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadMultipleImagesPage(
                      gym: widget.gym,
                    ),
                  ),
                ).then((_) => _loadVideosAndThumbnails());
              },
              child: Icon(Icons.add),
            ),
    );
  }
}
