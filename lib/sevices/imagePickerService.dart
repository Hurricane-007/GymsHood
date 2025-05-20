import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:uuid/uuid.dart';
// import 'image_file.dart'; // your ImageFile class file

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final uuid = Uuid();

  Future<List<ImageFile>> pickImages({bool allowMultiple = true}) async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) return [];

    List<ImageFile> imageFiles = [];
    for (final xfile in pickedFiles) {
      final bytes = await xfile.readAsBytes();
      imageFiles.add(
        ImageFile(
          uuid.v4(), // <- generate unique key
          name: xfile.name,
          extension: xfile.name.split('.').last,
          bytes: bytes,
          path: xfile.path,
        ),
      );
    }

    return imageFiles;
  }
}
