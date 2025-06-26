import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

class UploadMultipleImagesPage extends StatefulWidget {
  final Gym gym;
  const UploadMultipleImagesPage({super.key, required this.gym});

  @override
  State<UploadMultipleImagesPage> createState() => _UploadMultipleImagesPageState();
}

class _UploadMultipleImagesPageState extends State<UploadMultipleImagesPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool video = false;
  bool isUploading = false;
  late List<String> mediaUrls;

  @override
  void initState() {
    super.initState();
    mediaUrls = widget.gym.media?.mediaUrls ?? [];
  }

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
        SnackBar(
          content: Text("Please select at least one media"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      for (final file in _mediaFiles) {
        final mediaType = video ? 'video' : 'photo';
        final url = await uploadToServer(file, mediaType);
        mediaUrls.add(url);
      }
      
      final res = await Gymserviceprovider.server().addGymMedia(
        mediaType: 'photo',
        mediaUrl: mediaUrls,
        logourl: '',
        gymId: widget.gym.gymid,
      );
      
      showInfoDialog(context, res);
      setState(() {
        _mediaFiles.clear();
        isUploading = false;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String> uploadToServer(File file, String mediatype) async {
    try {
      final String res = await Fileserver().uploadToServer(file, mediatype, widget.gym.gymid);
      if (res is Exception) {
        showErrorDialog(context, "Media cannot be uploaded! please try again (info : Max size is 10MB)");
      }
      return res;
    } on DioException catch (e) {
      String errorMessage = "Network error occurred. Please check your internet connection.";
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timed out. Please try again.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Connection error. Please check your internet connection.";
      } else if (e.error is SocketException) {
        errorMessage = "Connection lost. Please check your internet connection and try again.";
      }
      
      showErrorDialog(context, errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      showErrorDialog(context, "An unexpected error occurred. Please try again.");
      throw Exception("Upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload Gym Media",
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Add Media to Your Gym',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'show case your gym with photos and videos. The media should be below 10MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(500),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                      
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          
                          boxShadow: [
                            
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withAlpha(400),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  video ? Icons.videocam : Icons.photo_library,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  video ? 'Video Upload' : 'Photo Upload',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            SwitchListTile(
                              value: video,
                              title: Text("Switch to Video Upload"),
                              onChanged: (value) => setState(() => video = value),
                              activeTrackColor: Theme.of(context).colorScheme.primary,
                              inactiveTrackColor: Colors.grey.shade300,
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickMedia,
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text(video ? "Select Videos" : "Select Photos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_mediaFiles.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Selected Media',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => setState(() => _mediaFiles.clear()),
                                    icon: Icon(Icons.delete_outline, color: Colors.red),
                                    label: Text('Clear All', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _mediaFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = _mediaFiles[index];
                                    return Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: video
                                                  ? Container(
                                                      color: Colors.black12,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.videocam,
                                                          size: 40,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.file(
                                                      file,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _mediaFiles.removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: isUploading ? null : uploadAllMedia,
                          icon: isUploading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.cloud_upload),
                          label: Text(isUploading ? "Uploading..." : "Upload All"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isUploading)
            Container(
              color: Colors.black.withAlpha(100),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Uploading Media...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
