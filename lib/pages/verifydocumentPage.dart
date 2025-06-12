import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import '../services/fileserver.dart';

class VerifyDocuments extends StatefulWidget {
  final Gym gym;
  const VerifyDocuments({super.key , required this.gym});

  @override
  State<VerifyDocuments> createState() => _VerifyDocumentsState();
}

class _VerifyDocumentsState extends State<VerifyDocuments> {
  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'Business Registration',
      'description': 'Upload your business registration certificate',
      'icon': Icons.business,
      'file': null,
      'uploaded': false,
    },
    {
      'name': 'Gym License',
      'description': 'Upload your gym operation license',
      'icon': Icons.fitness_center,
      'file': null,
      'uploaded': false,
    },
    {
      'name': 'Insurance Document',
      'description': 'Upload your gym insurance document',
      'icon': Icons.security,
      'file': null,
      'uploaded': false,
    },
  ];

  bool _isUploading = false;

  Future<void> _pickFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _documents[index]['file'] = result.files.first;
          _documents[index]['uploaded'] = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadDocuments() async {
    if (_isUploading) return;

    // Check if all documents are selected
    final missingDocs = _documents.where((doc) => doc['file'] == null).toList();
    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required documents')),
      );
     
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileServer = Fileserver();
      bool allUploaded = true;
      List<String> uploadeddocsurl = [];
      for (int i = 0; i < _documents.length; i++) {
        if (!_documents[i]['uploaded']) {
          final file = _documents[i]['file'] as PlatformFile;
          final result = await fileServer.uploadToServer(
            File(file.path!),
            'document',
            widget.gym.gymid
          );
          
          if (result != null) {
            uploadeddocsurl.add(result);
            setState(() {
              _documents[i]['uploaded'] = true;
            });
          } else {
            allUploaded = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload ${_documents[i]['name']}')),
            );
          }


        }
      }

      if (allUploaded) {
      //here add the logic to send the verification docs // Todo() Implementation
      await Gymserviceprovider.server().verificationdocsUpload(uploadeddocsurl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All documents uploaded successfully')),
        );
        showInfoDialog(context, " your status of pending verification will be changed once verified! ");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading documents: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: GestureDetector(
          onTap:() => Navigator.pop(context),
          child: Icon(Icons.arrow_back , color: Colors.white,)),
        title: Text('Verify Documents', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please upload the following documents for verification',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ..._documents.asMap().entries.map((entry) => 
              _buildDocumentField(entry.value, entry.key)
            ).toList(),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Submit Documents',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentField(Map<String, dynamic> doc, int index) {
    final file = doc['file'] as PlatformFile?;
    final isUploaded = doc['uploaded'] as bool;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(doc['icon'] as IconData, color: Theme.of(context).primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        doc['description']!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: isUploaded ? null : () => _pickFile(index),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isUploaded ? Colors.green : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUploaded ? Icons.check_circle : (file != null ? Icons.upload_file : Icons.upload),
                      color: isUploaded ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      isUploaded ? 'Uploaded' : (file != null ? file.name : 'Click to upload document'),
                      style: TextStyle(
                        color: isUploaded ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}