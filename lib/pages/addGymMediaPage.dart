import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/sevices/fileserver.dart';
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
  List<File> _mediaFiles = [];
  bool video = false;

  Future<void> _pickMedia() async {
    if (!video) {
      // Pick multiple images
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _mediaFiles = picked.map((xfile) => File(xfile.path)).toList();
        });
      }
    } else {
      // Pick multiple videos using file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _mediaFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    }
  }

  Future<void> uploadAllMedia() async {

    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one media")),
      );
      return;
    }

    for (final file in _mediaFiles) {
      final mediaType = video?'video':'photo';
      final mediaUrl = await uploadToServer(file , mediaType); // Replace with actual upload logic

      final success = await Gymserviceprovider.server().addGymMedia(
        mediaType: video ? 'video' : 'photo',
        mediaUrl: mediaUrl,
        logourl: '',
      );

      if (success != 'Successfully added Media') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload ${path.basename(file.path)}")),
        );
      } else {
        showInfoDialog(context, success);
      }
    }

    setState(() {
      _mediaFiles.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All media uploaded successfully!")),
    );
  }

  Future<String> uploadToServer(File file , String mediatype) async {
     final String res =  await Fileserver().uploadToServer(file , mediatype); 
     if(res is Exception){
      showErrorDialog(context, "Media cannot be uploaded! please try again (info : Max size is 10MB)");
     }
     return res;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Gym Media", style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickMedia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                overlayColor: Colors.white,
              ),
              child: Text(!video ? "Pick Images" : "Pick Videos", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: mq.height * 0.03),
            SwitchListTile(
              value: video,
              title: Text("Want to upload videos?"),
              onChanged: (value) => setState(() => video = value),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Colors.grey.shade300,
            ),
            SizedBox(height: mq.height * 0.1),
            _mediaFiles.isEmpty
                ? Text("No media selected")
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaFiles.length,
                      itemBuilder: (context, index) {
                        final file = _mediaFiles[index];
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.black12,
                                child: Center(
                                  child: video
                                      ? Icon(Icons.videocam, size: 40)
                                      : Image.file(file, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mediaFiles.removeAt(index);
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
            SizedBox(height: mq.height * 0.2),
            ElevatedButton(
              onPressed: uploadAllMedia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                overlayColor: Colors.white,
              ),
              child: Text("Upload All", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => setState(() => _mediaFiles.clear()),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Clear All", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
