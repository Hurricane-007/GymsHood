import 'dart:convert';
import 'dart:developer' as developer;

// import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/services/Auth/auth_server_provider.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/ActiveUsersModel.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/announcementModel.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/Models/ratingsModel.dart';
import 'package:gymshood/services/Models/registerModel.dart';
import 'package:gymshood/services/Models/revenueDataModel.dart';
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
      developer.log("Add gym media ${mediaUrl}");
      developer.log(logourl);
      final response = await dio.post('$baseUrl/gymdb/gym/$gymId/media',
          data: {
            'mediaUrls': mediaUrl,
            'logoUrl': logourl,
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        return 'Media updated successfully';
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
  Future<Map<String, dynamic>> registerGym(
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
            'coordinates': coordinates,
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
          'success': true,
          'message':
              "Successfully registered the gym will be notified once it's verified"
        };
      } else {
        developer.log(response.data['message']);
        return {'success': false, 'message': response.data['message']};
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return {
          'success': false,
          'message':
              "sorry gym cannot be created! try again"
        };
      } else {
        developer.log('Dio error: ${e.message}');
        return {'success': false, 'message': "sorry gym cannot be created! try again"};
      }
    } catch (e) {
      developer.log(e.toString());
      return {'success': false, 'message': e.toString()};
      // developer.log(e.toString());
    }
  }

  @override
  Future<bool> updateGym(
      {required String gymId,
      required String name,
      required Map<String, dynamic> location,
      required num capacity,
      required String openTime,
      required String closeTime,
      required String contactEmail,
      required String phone,
      required String about,
      required List<String> equipments,
      required List<Map<String, dynamic>> shifts}) async {
    try {
      final response = await dio.put(
        '$baseUrl/gymdb/gym/$gymId',
        data: {
          'name': name,
          'location': location,
          'capacity': capacity,
          'openTime': openTime,
          'closeTime': closeTime,
          'contactEmail': contactEmail,
          'phone': phone,
          'about': about,
          'shifts': shifts,
          'equipmentList': equipments
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log(response.data['message']);
        return false;
      }
    } catch (e) {
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
      required String gymId}) async {
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
  Future<bool> deletePlan({required String planId}) async {
    try {
      final response = await dio
          .put('$baseUrl/gymdb/plans/$planId', data: {'isActive': false});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? "Failed to delete plan");
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Gym>> getGymsByowner(String id) async {
    try {
      final response = await dio.get('$baseUrl/gymdb/gym/owner/$id');
      List<Gym> gyms = [];
      if (response.statusCode == 200) {
        final gymsjson = response.data['gyms'] as List<dynamic>;

        gyms = gymsjson
            .map<Gym>((json) => Gym.fromJson(json as Map<String, dynamic>))
            .toList();
        developer.log(gyms[0].gymid);
        return gyms;
      } else {
        developer.log(response.data['message'].toString());
        throw (Exception());
      }
    } catch (e) {
      developer.log(e.toString());
      return [];
    }
  }

  @override
  Future<bool> updatePlan(
      {required String planId,
      required String name,
      required num price,
      required num discountPercent,
      required String features,
      required num workoutDuration,
      required bool isTrainerIncluded}) async {
    try {
      final response = await dio.put('$baseUrl/gymdb/plans/$planId', data: {
        'name': name,
        'price': price,
        'discountPercent': discountPercent,
        'features': features,
        'duration': workoutDuration,
        'isTrainerIncluded': isTrainerIncluded
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log(response.data['message']);
        return false;
      }
    } catch (e) {
      developer.log(e.toString());
      return false;
    }
  }

  @override
  Future<GymDashboardStats> getgymDashBoardStatus(String gymId) async {
    try {
      final response = await dio.get('$baseUrl/gymdb/dashboard/stats/$gymId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return GymDashboardStats.fromJson(response.data['stats']);
      } else {
        developer.log('get gym dashboard error${response.data['message']}');
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      developer.log('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  @override
  Future<bool> verificationdocsUpload(List<String> docs) async {
    try {
      final response = await dio.put("$baseUrl/gymdb/gyms/verification",
          data: {'documentUrls': docs});
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log("error in verifying docs${response.data['message']}");
        return false;
      }
    } catch (e) {
      developer.log("error response in verifying docs${e.toString()}");
      return false;
    }
  }

  @override
  Future<bool> toggleGymstatus() async {
    try {
      final response = await dio.put("$baseUrl/gymdb/gyms/status");
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log("error in verifying docs ${response.data['message']}");
        return false;
      }
    } catch (e) {
      developer.log("error response in verifying docs${e.toString()}");
      return false;
    }
  }

  @override
  Future<GymAnnouncement> createGymAnnouncement(String message) async {
    try {
      final res = await dio.post("$baseUrl/gymdb/gyms/announcements",
          data: {'message': message});
      if (res.data['success'] == true) {
        final announcement = res.data['announcement'];

        final GymAnnouncement gymAnnouncement =
            GymAnnouncement.fromJson(announcement);
        return gymAnnouncement;
      } else {
        developer.log("Error in announcments ${res.data}");
        throw (Exception("some error occurred"));
      }
    } catch (e) {
      developer.log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<GymAnnouncement>> getGymAnnouncements() async {
    try {
      final response = await dio.get('$baseUrl/admin/announcements/user');
      developer.log("user announcement ${response.data['announcements']}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['announcements'];
        return data.map((json) => GymAnnouncement.fromJson(json)).toList();
      } else {
        developer.log("fetching error ");
        throw Exception("Failed to fetch announcements");
      }
    } catch (e) {
      developer.log("Error fetching announcements: $e");
      return [];
    }
  }

  @override
  Future<List<GymAnnouncement>> getGymAnnouncementsbygym() async {
    try {
      final response = await dio.get('$baseUrl/gymdb/announcements/gym');
      developer.log("user announcement ${response.data['announcements']}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['announcements'];
        return data.map((json) => GymAnnouncement.fromJson(json)).toList();
      } else {
        developer.log("fetching error ");
        throw Exception("Failed to fetch announcements");
      }
    } catch (e) {
      developer.log("Error fetching announcements: $e");
      return [];
    }
  }

  @override
  Future<GymRating> getgymrating(String gymID) async {
    try {
      final res = await dio.get("$baseUrl/gymdb/ratings/gym/$gymID");
      if (res.data['success']) {
        developer.log("data ${res.data}");
        return GymRating.fromJson(res.data['average']);
      } else {
        throw (Exception("error in fetching rating"));
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ActiveUsersResponse> getactiveUserResponse(String gymId) async {
    try {
      final response = await dio.get("$baseUrl/gymdb/gym/$gymId/active-users");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = {
          'activeUsers': (response.data['activeUsers'] as List)
              .map((json) => RegisterEntry.fromJson(json))
              .toList(),
          'expiredUsers': (response.data['expiredUsers'] as List)
              .map((json) => RegisterEntry.fromJson(json))
              .toList(),
          'activeCount': response.data['activeCount'],
          'expiredCount': response.data['expiredCount'],
        };
        return ActiveUsersResponse.fromJson(data);
      } else {
        developer.log(response.data['message']);
        throw (Exception("error in fetching gymregister"));
      }
    } catch (e) {
      developer.log(e.toString());
      rethrow;
    }
  }

  @override
Future<List<RevenueData>> fetchRevenueData(String gymId, {String period = 'monthly'}) async {
  try {
    final res = await dio.get(
      "$baseUrl/gymdb/dashboard/revenue/$gymId",
      queryParameters: {"period": period},
    );

    if (res.statusCode == 200 && res.data['success'] == true) {
      final revenueData = res.data['revenueData'];
      
      if (revenueData is List) {
        return revenueData
            .map((json) => RevenueData.fromJson(json))
            .toList();
      } else {
        developer.log("revenueData is not a list: $revenueData");
        return [];
      }
    } else {
      developer.log("error in revenue analytics ${res.data}");
      throw Exception("An error occurred");
    }
  } catch (e) {
    developer.log("error in revenue analytics $e");
    rethrow;
  }
}

// Future<List<RevenueData>> fetchRevenueData(String gymId, {String period = 'monthly'}) async {
//   await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

//   final fixedDate = DateTime(2025, 6, 13); // Fixed current date for consistency
//   final currentYear = fixedDate.year;

//   // Helper for ISO week number
//   int getWeekNumber(DateTime date) {
//     final firstDayOfYear = DateTime(date.year, 1, 1);
//     final daysPassed = date.difference(firstDayOfYear).inDays;
//     return ((daysPassed + firstDayOfYear.weekday) / 7).ceil();
//   }

//   switch (period) {
//     case 'daily':
//       final month = fixedDate.month;
//       final day = fixedDate.day;
//       return [
//         RevenueData(
//           period: {"year": currentYear, "month": month, "day": day},
//           planId: "plan_basic_001",
//           planName: "Basic Fitness",
//           totalRevenue: 1400,
//           transactionCount: 3,
//         ),
//         RevenueData(
//           period: {"year": currentYear, "month": month, "day": day},
//           planId: "plan_premium_001",
//           planName: "Premium Plus",
//           totalRevenue: 2700,
//           transactionCount: 5,
//         ),
//         RevenueData(
//           period: {"year": currentYear, "month": month, "day": day},
//           planId: "plan_annual_001",
//           planName: "Annual Pro",
//           totalRevenue: 3300,
//           transactionCount: 2,
//         ),
//         RevenueData(
//           period: {"year": currentYear, "month": month, "day": day},
//           planId: "plan_student_001",
//           planName: "Student Saver",
//           totalRevenue: 900,
//           transactionCount: 2,
//         ),
//       ];

//     case 'weekly':
//       return [
//         // Week 22 (End of May)
//         RevenueData(
//           period: {"year": 2025, "week": 22},
//           planId: "plan_basic_001",
//           planName: "Basic Fitness",
//           totalRevenue: 3000,
//           transactionCount: 4,
//         ),
//         RevenueData(
//           period: {"year": 2025, "week": 22},
//           planId: "plan_premium_001",
//           planName: "Premium Plus",
//           totalRevenue: 5200,
//           transactionCount: 3,
//         ),

//         // Week 23 (Start of June)
//         RevenueData(
//           period: {"year": 2025, "week": 23},
//           planId: "plan_annual_001",
//           planName: "Annual Pro",
//           totalRevenue: 7600,
//           transactionCount: 3,
//         ),
//         RevenueData(
//           period: {"year": 2025, "week": 23},
//           planId: "plan_student_001",
//           planName: "Student Saver",
//           totalRevenue: 1900,
//           transactionCount: 2,
//         ),
//       ];

//     case 'monthly':
//     default:
//       return [
//         // April 2025
//         RevenueData(
//           period: {"year": 2025, "month": 4},
//           planId: "plan_basic_001",
//           planName: "Basic Fitness",
//           totalRevenue: 4500,
//           transactionCount: 5,
//         ),
//         RevenueData(
//           period: {"year": 2025, "month": 4},
//           planId: "plan_premium_001",
//           planName: "Premium Plus",
//           totalRevenue: 7000,
//           transactionCount: 4,
//         ),

//         // May 2025
//         RevenueData(
//           period: {"year": 2025, "month": 5},
//           planId: "plan_annual_001",
//           planName: "Annual Pro",
//           totalRevenue: 8800,
//           transactionCount: 3,
//         ),
//         RevenueData(
//           period: {"year": 2025, "month": 5},
//           planId: "plan_student_001",
//           planName: "Student Saver",
//           totalRevenue: 2200,
//           transactionCount: 2,
//         ),

//         // June 2025
//         RevenueData(
//           period: {"year": 2025, "month": 6},
//           planId: "plan_basic_001",
//           planName: "Basic Fitness",
//           totalRevenue: 6200,
//           transactionCount: 7,
//         ),
//         RevenueData(
//           period: {"year": 2025, "month": 6},
//           planId: "plan_premium_001",
//           planName: "Premium Plus",
//           totalRevenue: 11500,
//           transactionCount: 6,
//         ),
//       ];
//   }
// }



//   Future<List<RevenueData>> fetchRevenueData(String gymId,
//     {String period = 'monthly'}) async {
//   await Future.delayed(const Duration(milliseconds: 500)); // simulate network delay

//   final List<Map<String, dynamic>> mockRevenueData = [
//     // Monthly - Plan A
//     {
//       "period": { "year": 2025, "month": 5, "planId": "plan123" },
//       "planId": "plan123",
//       "planName": "Monthly Pro Plan",
//       "totalRevenue": 12000.0,
//       "transactionCount": 48
//     },
//     // Monthly - Plan B
//     {
//       "period": { "year": 2025, "month": 5, "planId": "plan456" },
//       "planId": "plan456",
//       "planName": "Monthly Basic Plan",
//       "totalRevenue": 4500.0,
//       "transactionCount": 30
//     },
//     // Weekly - Plan A
//     {
//       "period": { "year": 2025, "week": 22, "planId": "plan123" },
//       "planId": "plan123",
//       "planName": "Monthly Pro Plan",
//       "totalRevenue": 3000.0,
//       "transactionCount": 12
//     },
//     // Daily - Plan B
//     {
//       "period": { "year": 2025, "month": 6, "day": 10, "planId": "plan456" },
//       "planId": "plan456",
//       "planName": "Monthly Basic Plan",
//       "totalRevenue": 500.0,
//       "transactionCount": 3
//     }
//   ];

//   return mockRevenueData.map((e) => RevenueData.fromJson(e)).toList();
// }


  @override
  Future<bool> createFundaccount(String upiId, String accountNumber,
      String ifscCode, String accountHolder) async {
    try {
      final res = await dio.post("$baseUrl/gymdb/create-paymentContactinfo");
      if (res.statusCode == 201 && res.data['success']) {
        return true;
      } else {
        throw (Exception("error occured in creating the account"));
      }
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<bool> recreateFundaccount(String upiId, String accountNumber,
      String ifscCode, String accountHolder) async {
    try {
      final res = await dio.post("$baseUrl/gymdb/udpate-paymentContactInfo");
      if (res.statusCode == 201 && res.data['success']) {
        return true;
      } else {
        throw (Exception("error occured in creating the account"));
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<bool> deleteAnnouncement(String announcementId) async{
    try{
      final res = await dio.delete(
        "$baseUrl/gymdb/announcements/gym/$announcementId"
      );
      if(res.statusCode == 200){
        return true;
      }else{
        developer.log("error in deleting announcement ${res.data}");
        return false;
      }
    }catch(e){
      developer.log("error in deleting announcement $e");
      return false;
    }
  }
}
