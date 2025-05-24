import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/sevices/Auth/auth_server_provider.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Models/AuthUser.dart';
import 'package:gymshood/sevices/Models/gym.dart';
import 'package:gymshood/sevices/gymInfo/gymserviceprovider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class Fileserver {
  // final dio = ServerProvider().dio;
    late final Dio _dio;
  Fileserver._internal(){
    _dio=Dio();
  }

  static final Fileserver _instance = Fileserver._internal();

  factory Fileserver() => _instance;
  final baseurl = dotenv.env['BASE_URL_FILE_SERVER'];

  Future<String> uploadToServer(File file , String mediaType ) async {
 // use your configured Dio instance if needed
  // gymer
  final Authuser? auth = await AuthService.server().getUser();

// final List<Gym> gym = await Gymserviceprovider.server().getAllGyms(search: auth!.userid );
// developer.log(gym.length.toString());
String gymId = auth!.userid!;
// for(Gym g in gym){
//   gymId = g.gymid;
// }
// for(Gym g in gym){
//  developer.log(g.name);
// }
//   try {
//   // final res = await _dio.get('$baseurl/files');
//   // developer.log('✅ Connection to file server successful: ${res.data}');
// } catch (e) {
//   developer.log('❌ Cannot connect to file server: $e');
// }
  final filename = path.basename(file.path);
  final fileext = path.extension(file.path);
  final customfilename = '${gymId}_$mediaType$filename';

  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path, filename: customfilename , 
    ),
  });
    // developer.log("$baseurl/upload");
  try {
    final response = await _dio.post(
      '$baseurl/upload', // your actual endpoint
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          // Include auth header if you're using tokens
          // 'Authorization': 'Bearer yourToken'
        },
      ),
    );

    if (response.statusCode == 201 && response.data['url'] != null) {
      return response.data['url']; // backend gives you this URL
    } else {
      developer.log('${response.data},${response.statusCode}');
      throw Exception('Upload failed');
    }
  }on DioException catch(e){
    developer.log(e.toString());
    throw Exception(e.toString());
  }
   catch (e) {
    developer.log('Upload error: $e');
    throw Exception('Upload failed');
  }
}

Future<List<String>> getallfiles()async{
  try{
    final res = await _dio.get('$baseurl/files');
    if(res.statusCode == 200){
      final data = res.data;
      if(data['success'] == true){
        final  files = data['files'];
        // developer.log(files.runtimeType.toString());
        return files.map<String>((file) => file['url'] as String).toList();
      }
    }
  }catch(e){
      developer.log('Error fetching files: $e');
    }
    return [];
}

Future<List<String>> fetchMediaUrls(String mediaType) async {
  final Authuser? auth = await AuthService.server().getUser();
  final String gymId = auth!.userid!;

  final response = await _dio.get(
    '$baseurl/files',
    queryParameters: {
      'prefix': gymId,
    },
  );

  if (response.data['success'] == true) {
    final files = List<String>.from(response.data['files'].map((f) => f['url']));

    final photos = <String>[];
    final videos = <String>[];
    final logos = <String>[];

    for (final url in files) {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      final filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last.toLowerCase() : '';

      if (filename.contains('logo')) {
        logos.add(url);
      } else if (path.endsWith('.jpg') ||
                 path.endsWith('.jpeg') ||
                 path.endsWith('.png') ||
                 path.endsWith('.webp')) {
        photos.add(url);
      } else if (path.endsWith('.mp4') ||
                 path.endsWith('.mov') ||
                 path.endsWith('.avi') ||
                 path.endsWith('.mkv')) {
        videos.add(url);
      }
    }

    if (mediaType.toLowerCase() == 'logo') {
      return logos;
    } else if (mediaType.toLowerCase() == 'photo') {
      return photos;
    } else {
      return videos;
    }
  } else {
    throw Exception('Failed to fetch media URLs');
  }
}


Future<bool> deleteFileFromServer(String filename) async {
  // final dio = Dio();

  try {
    final response = await _dio.delete(
      '$baseurl/files/$filename',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      developer.log('File deleted successfully: ${response.data['filename']}');
      return true;
    } else {
      developer.log('Failed to delete file: ${response.data}');
      return false;
    }
  } catch (e) {
    developer.log('Error while deleting file: $e');
    return false;
    
  }
}

}