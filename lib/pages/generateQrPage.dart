import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final TextEditingController _textController = TextEditingController();
  String _qrData = '';
  bool _isGenerating = false;
  final GlobalKey _qrKey = GlobalKey();
  String gymId = '';
  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    getGymId();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _qrData = _textController.text;
    });
  }

  Future<void> getGymId() async {
    try {
      final Authuser? auth = await AuthService.server().getUser();
      final List<Gym> gym = await Gymserviceprovider.server().getGymsByowner(auth!.userid!);
      if (gym.isNotEmpty) {
        setState(() {
          gymId = gym[0].gymid;
          _qrData = gymId; // Set QR data to gym ID
          _textController.text = gymId; // Update text controller
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading gym data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQRCode() async {
    if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
      if (_qrData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter some text to generate QR code'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        setState(() {
          _isGenerating = true;
        });

        // Generate QR code as image using QrPainter
        final qrPainter = QrPainter(
          data: _qrData,
          version: QrVersions.auto,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: true,
        );

        final qrImage = await qrPainter.toImageData(2048);
        if (qrImage != null) {
          final buffer = qrImage.buffer;
          final imageBytes = buffer.asUint8List(qrImage.offsetInBytes, qrImage.lengthInBytes);
          
          // Save to external storage
          try {
            final directory = await getExternalStorageDirectory();
            if (directory != null) {
              final picturesDir = Directory('${directory.path}/Pictures');
              if (!await picturesDir.exists()) {
                await picturesDir.create(recursive: true);
              }
              
              final fileName = 'gym_qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
              final filePath = '${picturesDir.path}/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(imageBytes);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR Code saved successfully!\nPath: $filePath'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Share',
                    onPressed: () => _shareQRCode(imageBytes),
                  ),
                ),
              );
            } else {
              throw Exception('Could not access external storage');
            }
          } catch (e) {
            developer.log('External storage save error: $e');
            // Fallback: save to temporary directory and share
            await _saveToTempAndShare(imageBytes);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate QR code image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        developer.log('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isGenerating = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save QR code.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveToTempAndShare(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR Code saved to temporary location. You can share it now.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _shareQRCode(imageBytes),
          ),
        ),
      );
    } catch (e) {
      developer.log('Temp save error: $e');
      // Last resort: copy gym ID to clipboard
      Clipboard.setData(ClipboardData(text: _qrData));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save image. Gym ID copied to clipboard instead.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareQRCode(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(path)],
        text: 'QR Code for Gym Access\nGym ID: $_qrData',
        subject: 'Gym QR Code',
      );
    } catch (e) {
      developer.log('Share error: $e');
      // Fallback: share text only
      await Share.share(
        'Gym QR Code\nGym ID: $_qrData\n\nScan this QR code to access gym services.',
        subject: 'Gym QR Code',
      );
    }
  }

  Future<void> _shareQRCodeDirectly() async {
    try {
      // Generate QR code as image
      final qrPainter = QrPainter(
        data: _qrData,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
      );

      final qrImage = await qrPainter.toImageData(2048);
      if (qrImage != null) {
        final buffer = qrImage.buffer;
        final imageBytes = buffer.asUint8List(qrImage.offsetInBytes, qrImage.lengthInBytes);
        await _shareQRCode(imageBytes);
      } else {
        // Fallback: share text only
        await Share.share(
          'Gym QR Code\nGym ID: $_qrData\n\nScan this QR code to access gym services.',
          subject: 'Gym QR Code',
        );
      }
    } catch (e) {
      developer.log('Share directly error: $e');
      // Fallback: share text only
      await Share.share(
        'Gym QR Code\nGym ID: $_qrData\n\nScan this QR code to access gym services.',
        subject: 'Gym QR Code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Generator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Gym QR Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This QR code contains your gym ID for easy access',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Gym ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Icon(
                          Icons.copy,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {
                        // Copy gym ID to clipboard
                        if (_textController.text.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: _textController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gym ID copied to clipboard'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code Display Section
            if (_qrData.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Your Gym QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: RepaintBoundary(
                          key: _qrKey,
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating ? null : _saveQRCode,
                              icon: _isGenerating 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                              label: Text(_isGenerating ? 'Saving...' : 'Save to Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _qrData.isNotEmpty ? _shareQRCodeDirectly : null,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Placeholder when no data
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        gymId.isEmpty ? 'Loading gym data...' : 'No gym data available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (gymId.isEmpty) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}