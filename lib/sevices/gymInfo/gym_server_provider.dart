import 'dart:developer' as developer;

// import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/sevices/Auth/auth_server_provider.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Models/AuthUser.dart';
import 'package:gymshood/sevices/Models/gym.dart';
import 'package:gymshood/sevices/gymInfo/gymowner_info_provider.dart';

class GymServerProvider implements GymOwnerInfoProvider  {
     final String? baseUrl = dotenv.env['BASE_URL'];
   final Dio dio = ServerProvider().dio;
    
  @override
  Future<String> addGymMedia({
    required String mediaType,
     required String mediaUrl, 
     required String logourl,
     required }) async{
    // Authuser? user = await AuthService.server().getUser();
    try{
        final response = await dio.post(
                '$baseUrl/gym/682b6695d64293ae028027ed/media',  
                  data: {'mediaType': mediaType,
                   'mediaUrl': mediaUrl, 
                   'logourl': logourl,},
          options: Options(headers: {'Content-Type': 'application/json'})
        );

        if(response.statusCode == 201){
          return 'Successfully added Media';
        }else{
          return response.data['message'];
        }
    }on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return e.response?.data;
      } else {
        developer.log('Dio error: ${e.message}');
        return e.message!;
      }
    } catch (e) {
      return e.toString();
      // developer.log(e.toString());
    }
   
  }

  @override
  Future<Gym> getGymDetails({required String id}) {
    // TODO: implement getGymDetails
    throw UnimplementedError();
  }

  @override
  Future<String> registerGym({
    required String role,
     required String name, 
     required String location,
      List<num>? coordinates,
       required num capacity,
        required String openTime,
         required String closeTime, 
         required String contactEmail, 
         required String phone, 
         required String about, 
         required List<String> equipmentList, 
         required List<Map<String, Object>> shifts, 
         required String userid})async {
         
         try{
          // dev
          final Authuser? user = await ServerProvider().getUser();
          final response = await dio.post(
            '$baseUrl/gym/register' , data: {
                   'role': user!.role,
                   'name': user.name, 
                   'location': location,
                   'coordinates':coordinates,
                   'capacity':capacity,
                   'openTime':openTime,
                   'closeTime':closeTime,
                   'contactEmail':contactEmail,
                   'phone':phone,
                   'about':about,
                   'equipmentList':equipmentList,
                   'shifts':shifts
                   
                   },
          options: Options(headers: {'Content-Type': 'application/json'})
          );

          if(response.statusCode==201) {return 
          "Successfully registered gym , will be notified once verified";}
          else {
            developer.log(response.data['message']);
            return response.data['message'];
            }
         }on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return e.response?.data;
      } else {
        developer.log('Dio error: ${e.message}');
        return '${e.message}';
      }
    } catch (e) {
      return e.toString();
      // developer.log(e.toString());
    }
  }

  @override
  Future<bool> updateGym({required String name, required String location, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required String shifts}) {
    // TODO: implement updateGym
    throw UnimplementedError();
  }
  
  @override
  Future<String> createPlan({
    required String name, 
    required num validity, 
    required num price,
     required num discountPercent,
      required String features, 
      required String planType,
       required bool isTrainerIncluded, 
       required String workoutDuration}) async {
          try{

            final response = await dio.post(
              '$baseUrl/682b6695d64293ae028027ed/plans',data: {
                'name' : name,
                'validity':validity,
                'price':price,
                'discountPercent':discountPercent,
                'features':features,
                'planType':planType,
                'isTrainerIncluded':isTrainerIncluded,
                'workoutDuration':workoutDuration
              },
              options: Options(headers: {'Content-Type': 'application/json'}),
            );

            if(response.statusCode==201){
              return "Successfull";
            }
            else{
              return response.data['message'];
            }
          }on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return '${e.response?.data['message']}';
      } else {
        developer.log('Dio error: ${e.message}');
        return '${e.message}';
      }
    } catch(e){
              return e.toString();
          }
  }

  @override
Future<List<Gym>> getAllGyms({
  String? status,
  String? search,
  String? near, // Format: "lat,lng,radius"
}) async {
  try {
    final queryParams = <String, dynamic>{};

    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (near != null) queryParams['near'] = near;

    final response = await dio.get(
      '$baseUrl/admin/gyms',
      queryParameters: queryParams,
    );
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final responseData = response.data;
      // developer.log(responseData.runtimeType.toString());
      List<Gym> gyms = [];

      if (responseData is Map<String, dynamic> && responseData.containsKey('gyms')) {
        final gymsJson = responseData['gyms'] as List<dynamic>;
          gyms = gymsJson
      .map<Gym>((json) => Gym.fromJson(json as Map<String, dynamic>))
      .toList();
      } else {
        developer.log('Unexpected data type for "gyms": ${responseData.runtimeType}');
      }
      if(gyms.isEmpty) throw Exception();
      return gyms;
    }
  } catch (e) {
    developer.log('Error fetching gyms: $e');
  }
  throw Exception();
  // return [];
}

}