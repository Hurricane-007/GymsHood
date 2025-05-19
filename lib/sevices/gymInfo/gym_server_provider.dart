import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/sevices/Auth/auth_server_provider.dart';
import 'package:gymshood/sevices/Models/gym.dart';
import 'package:gymshood/sevices/gymInfo/gymowner_info_provider.dart';

class GymServerProvider implements GymOwnerInfoProvider{
     final String? baseUrl = dotenv.env['BASE_URL'];
   final Dio dio = ServerProvider().dio;

  @override
  Future<bool> addGymMedia({
    required String mediaType,
     required String mediaUrl, 
     required String logourl,}) async{
    
    try{
        final response = await dio.post(
                '$baseUrl/gym/:id/media',  
                  data: {'mediaType': mediaType,
                   'mediaUrl': mediaUrl, 
                   'logourl': logourl,},
          options: Options(headers: {'Content-Type': 'application/json'})
        );

        if(response.statusCode == 201){
          return true;
        }else{
          return false;
        }
    }on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return false;
      } else {
        developer.log('Dio error: ${e.message}');
        return false;
      }
    } catch (e) {
      return false;
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
          final response = await dio.post(
            '$baseUrl/gym/register' , data: {
                   'role': role,
                   'name': name, 
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
}