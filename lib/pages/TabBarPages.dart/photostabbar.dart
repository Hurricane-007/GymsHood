import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/FullScreenPage.dart';
import 'package:gymshood/pages/createServicesPages/addGymMediaPage.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/ratingsModel.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class PhotosTabBar extends StatefulWidget {
  final Gym gym;
  const PhotosTabBar({super.key, required this.gym});

  @override
  State<PhotosTabBar> createState() => _PhotosTabBarState();
}

class _PhotosTabBarState extends State<PhotosTabBar> {
  List<String> _imageUrls = [];
  bool _selectionMode = false;
  final Set<String> _selectedUrls = {};

  bool _isImageFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
  }

  @override
  void initState() {
    
    super.initState();
 
    _imageUrls = (widget.gym.media?.mediaUrls ?? [])
        .where((url) => _isImageFile(url))
        .toList();
    developer.log("Images : $_imageUrls");
    developer.log("gym : ${widget.gym.media}");
  }

  Future<void> _refreshImages() async {
    setState(() {
      _imageUrls = (widget.gym.media?.mediaUrls ?? [])
          .where((url) => _isImageFile(url))
          .toList();
      _selectedUrls.clear();
      _selectionMode = false;
    });
  }

  void _toggleSelection(String url) {
    setState(() {
      if (_selectedUrls.contains(url)) {
        _selectedUrls.remove(url);
        if (_selectedUrls.isEmpty) _selectionMode = false;
      } else {
        _selectedUrls.add(url);
        _selectionMode = true;
      }
    });
  }

  Future<void> _deleteSelectedImages() async {
    final confirm = await showDeleteDialog(context);
    if (!confirm) return;
    
    bool allSuccess = true;
    List<String> mediaUrls;
    mediaUrls = widget.gym.media!.mediaUrls;
    // mediaUrls = [];
    for (var url in _selectedUrls) {
     mediaUrls.remove(url);
    }
    final success = await Gymserviceprovider.server().addGymMedia(
      mediaType: 'photo',
      mediaUrl: mediaUrls,
      logourl: widget.gym.media!.logoUrl,
      gymId: widget.gym.gymid
    );
    if (success != 'Media updated successfully') allSuccess = false;
    developer.log(success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allSuccess ? 'Selected photos deleted successfully' : 'Some deletions failed',
        ),
      ),
    );
    _refreshImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageUrls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo , size: 60,),
                  Text('No images available'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadMultipleImagesPage(
                            gym: widget.gym,
                          ),
                        ),
                      ).then((_) => _refreshImages());
                    },
                    child: Text('Add Images'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                final url = _imageUrls[index];
                return GestureDetector(
                  onTap: _selectionMode
                      ? () => _toggleSelection(url)
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                imageUrl: url,
                                gym: widget.gym,
                              ),
                            ),
                          );
                        },
                  onLongPress: () {
                    if (!_selectionMode) {
                      setState(() {
                        _selectionMode = true;
                        _selectedUrls.add(url);
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                      if (_selectionMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedUrls.contains(url)
                                  ? Colors.blue
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.check,
                              color: _selectedUrls.contains(url)
                                  ? Colors.white
                                  : Colors.transparent,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: _selectionMode
          ? FloatingActionButton(
              onPressed: _deleteSelectedImages,
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
                ).then((_) => _refreshImages());
              },
              child: Icon(Icons.add),
            ),
    );
  }
}
