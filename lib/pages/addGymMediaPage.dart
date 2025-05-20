import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/sevices/gymInfo/gymserviceprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UploadMultipleImagesPage extends StatefulWidget {
  const UploadMultipleImagesPage({super.key});

  @override
  State<UploadMultipleImagesPage> createState() => _UploadMultipleImagesPageState();
}

class _UploadMultipleImagesPageState extends State<UploadMultipleImagesPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _images = picked;
      });
    }
  }

  Future<void> uploadAllImages() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one image")),
      );
      return;
    }


    for (final image in _images) {
      final file = File(image.path);
      final mediaUrl = await uploadToServer(file); // Replace with actual upload logic

      final success = await Gymserviceprovider.server().addGymMedia(
        mediaType: 'photo',
        mediaUrl: mediaUrl,
        logourl: '', // Add logic if needed
      );

      if (success != 'Successfully added Media') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload ${path.basename(file.path)}")),
        );
      }else{
        showErrorDialog(context, success);
      }
    }

        setState(() {
      _images.clear();
      _images = [];
    });


    

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All media uploaded successfully!")),
    );
  }

  Future<String> uploadToServer(File file) async {
    // Replace with actual backend logic
    await Future.delayed(Duration(seconds: 1)); // Simulate upload delay
    return 'https://yourserver.com/uploads/${path.basename(file.path)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Gym Media", style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text("Pick Images", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            _images.isEmpty
                ? Text("No images selected")
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(
                                File(_images[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                                child: Container(
                                  color: Colors.black54,
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadAllImages,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text("Upload All", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _images.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Clear All", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
