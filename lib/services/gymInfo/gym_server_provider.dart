import 'dart:convert';
import 'dart:developer' as developer;

// import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/services/Auth/auth_server_provider.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/gymInfo/gymowner_info_provider.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class GymServerProvider implements GymOwnerInfoProvider {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final Dio dio = ServerProvider().dio;

  @override
  Future<String> addGymMedia(
      {required String mediaType,
      required List<String> mediaUrl,
      required String logourl,
      required String gymId}) async {
    // Authuser? user = await AuthService.server().getUser();
    try {

      final response =
          await dio.post('$baseUrl/gymdb/gym/$gymId/media',
              data: {
                'mediaType': mediaType,
                'mediaUrls': mediaUrl,
                'logourl': logourl,
              },
              options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        return 'Successfully added Media';
      } else {
        return response.data['message'];
      }
    } on DioException catch (e) {
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
  Future<Gym> getGymDetails({required String id}) async {
    try {
      final response = await dio.get('$baseUrl/gymdb/gym/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['gym'];

        // developer.log(data.toString());
        return Gym.fromJson(data);
      } else {
        developer.log('error occured');
        throw Exception('Failed to load gym data');
      }
    } catch (e) {
      developer.log('error occured: $e');
      rethrow; // Let the calling function handle the exception
    }
  }

  @override
  Future<Map<String,dynamic>> registerGym(
      {required String role,
      required String name,
      required String location,
     required List<num> coordinates,
     required String gymSlogan,
      required num capacity,
      required String openTime,
      required String closeTime,
      required String contactEmail,
      required String phone,
      required String about,
      required List<String> equipmentList,
      required List<Map<String, Object>> shifts,
      required String userid}) async {
    try {
      // dev
      final Authuser? user = await ServerProvider().getUser();
      developer.log(coordinates.toString());
      final response = await dio.post('$baseUrl/gymdb/gym/register',
          data: {
            'role': user!.role,
            'name': name,
            'location': location,
            'coordinates':coordinates,
            'capacity': capacity,
            'openTime': openTime,
            'closeTime': closeTime,
            'contactEmail': contactEmail,
            'phone': phone,
            'about': about,
            'equipmentList': equipmentList,
            'gymSlogan': gymSlogan,
            'shifts': shifts
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        return {
            'success':true,
            'message':"Successfully registered the gym will be notified once it's verified"
        };
      } else {
        developer.log(response.data['message']);
        return {
            'success':false,
            'message':response.data['message']
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return {
            'success':false,
            'message':"Successfully registered the gym will be notified once it's verified"
        };
      } else {
        developer.log('Dio error: ${e.message}');
        return  {
            'success':false,
            'message':"${e.message}"
        };
      }
    } catch (e) {
      developer.log(e.toString());
       return {
            'success':false,
            'message':e.toString()
        };
      // developer.log(e.toString());
    }
  }

  @override
  Future<bool> updateGym(
      { required String gymId,
        required String name,
      required Map<String,dynamic> location,
      required num capacity,
      required String openTime,
      required String closeTime,
      required String contactEmail,
      required String phone,
      required String about,
      required List<Map<String,dynamic>> shifts}) async{
        
        try{
          final response = await dio.put('$baseUrl/gymdb/gym/$gymId',
            data: {
                'name':name,
                'location':location,
                'capacity':capacity,
                'openTime':openTime,
                'closeTime':closeTime,
                'contactEmail':contactEmail,
                'phone':phone,
                'about':about,
                'shifts':shifts
            },

          );
          if(response.statusCode == 200){
            return true;
          }else{
            developer.log(response.data['message']);
            return false;
          }

        }catch(e){
          developer.log(e.toString());
            return false;
        }
  }

  @override
  Future<String> createPlan(
      {required String name,
      required num validity,
      required num price,
      required num discountPercent,
      required String features,
      required String planType,
      required bool isTrainerIncluded,
      required num workoutDuration,
      required String gymId
     }) async {
    try {

      final response = await dio.post(
        '$baseUrl/gymdb/$gymId/plans',
        data: {
          'name': name,
          'validity': validity,
          'price': price,
          'discountPercent': discountPercent,
          'features': features,
          'planType': planType,
          'isTrainerIncluded': isTrainerIncluded,
          'duration': workoutDuration
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        return "Successfull";
      } else {
        return response.data['message'];
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return '${e.response?.data['message']}';
      } else {
        developer.log('Dio error: ${e.message}');
        return '${e.message}';
      }
    } catch (e) {
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
        '$baseUrl/gymdb/gyms',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;
        // developer.log(responseData.toString());
        List<Gym> gyms = [];

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('gyms')) {
          final gymsJson = responseData['gyms'] as List<dynamic>;
          gyms = gymsJson
              .map<Gym>((json) => Gym.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          developer.log(
              'Unexpected data type for "gyms": ${responseData.runtimeType}');
        }
        if (gyms.isEmpty) throw Exception();
        return gyms;
      }
    } catch (e) {
      developer.log('Error fetching gyms: $e');
    }
    throw Exception();
    // return [];
  }

  @override
  Future<List<Plan>> getPlans(String gymId) async {
       
    try {
      final response = await dio.get('$baseUrl/gymdb/plans/gym/$gymId');
      // developer.log(',GymID: $gymId');
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['plans'];
        // developer.log(data.toString());
        return data.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch plans");
      }
    } catch (e) {
      throw Exception("Error fetching plans: $e");
    }
  }
  
  @override
  Future<bool> deletePlan({required String planId}) async{
        try {
      final response = await dio.put('$baseUrl/gymdb/plans/$planId' , data: {
        'isActive':false
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? "Failed to delete plan");
      }
    } catch (e) {      return false;
    }
    }
@override
  Future<List<Gym>> getGymsByowner(String id)async{
    try{
        final response = await dio.get('$baseUrl/gymdb/gym/owner/$id');
        List<Gym> gyms = [];
        if(response.statusCode==200){
          final gymsjson = response.data['gyms'] as List<dynamic>;

          
          gyms = gymsjson.map<Gym>((json) => Gym.fromJson(json as Map<String,dynamic>)).toList();
          developer.log(gyms[0].gymid);
          return gyms;
        }
        else{
          developer.log(response.data['message'].toString());
          throw(Exception());
        }
    }catch(e){
      developer.log(e.toString());
      return [];
    }
  }
  
  @override
  Future<bool> updatePlan({required String planId, required String name, required num price, required num discountPercent, required String features, required num workoutDuration, required bool isTrainerIncluded}) async{
    try{
      final response = await dio.put(
          '$baseUrl/gymdb/plans/$planId',
          data: {
             'name':name,
              'price':price,
              'discountPercent':discountPercent,
              'features':features,
              'duration':workoutDuration,
              'isTrainerIncluded':isTrainerIncluded
          }
      );
      if(response.statusCode==200){
        return true;
      }else{
        developer.log(response.data['message']);
        return false;
      }
    }catch(e){
      developer.log(e.toString());
            return false;
          }
  }
  
  @override
  Future<GymDashboardStats> getgymDashBoardStatus(String gymId) async {
    try {
      final response = await dio.get('$baseUrl/dashboard/stats/$gymId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return GymDashboardStats.fromJson(response.data['stats']);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      developer.log('Error fetching dashboard stats: $e');
      rethrow;
    }
  }
}
