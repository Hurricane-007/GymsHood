import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/FullScreenPage.dart';
import 'package:gymshood/pages/addGymMediaPage.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';

class PhotosTabBar extends StatefulWidget {
  final Gym gym;
  const PhotosTabBar({super.key, required this.gym});

  @override
  State<PhotosTabBar> createState() => _PhotosTabBarState();
}

class _PhotosTabBarState extends State<PhotosTabBar> {
  late Future<List<String>> _futureImages;
  List<String> _imageUrls = [];

  bool _selectionMode = false;
  final Set<String> _selectedUrls = {};

  @override
  void initState() {
    super.initState();
    _futureImages = _loadImages();
  }

  Future<List<String>> _loadImages() async {
    final urls = await Fileserver().fetchMediaUrls('photo' , widget.gym.gymid);
    setState(() {
      _imageUrls = urls;
    });
    return urls;
  }

  Future<void> _refreshImages() async {
    setState(() {
      _futureImages = _loadImages();
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
    for (var url in _selectedUrls) {
      final filename = url.split('/').last;
      final success = await Fileserver().deleteFileFromServer(filename);
      if (!success) allSuccess = false;
    }

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
      appBar: _selectionMode?  AppBar(
        backgroundColor: Theme.of(context).primaryColor,
             title: Text(_selectionMode
            ? "${_selectedUrls.length} selected"
            : "Photos" , style: TextStyle(color: Colors.white),),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete , color: Colors.white,),
                  onPressed: _deleteSelectedImages,
                )
              ]
            : [],
            ):null,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Theme.of(context).primaryColor,
        onRefresh: _refreshImages,
        child: FutureBuilder<List<String>>(
          future: _futureImages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final imageUrls = snapshot.data ?? [];
            if (imageUrls.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_album, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("No Photos Available", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UploadMultipleImagesPage(gym: widget.gym,)),
                        );
                        _refreshImages();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Photo"),
                    ),
                  ],
                ),
              );
            }

            return GridView.count(
              crossAxisCount: 2,
              children: imageUrls.map((url) {
                final isSelected = _selectedUrls.contains(url);
                return GestureDetector(
                  onTap: () async{
                    if (_selectionMode) {
                      _toggleSelection(url);
                    } else {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(imageUrl: url),
                        ),
                      );

                        
                          _refreshImages();
                        
                    }
                  },
                  onLongPress: () {
                    _toggleSelection(url);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          color: isSelected ? Colors.black.withValues(alpha: 0.6) : null,
                          colorBlendMode: isSelected ? BlendMode.darken : null,
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.check_circle, color: Colors.white, size: 28),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
