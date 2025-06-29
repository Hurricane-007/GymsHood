// import 'dart:ffi';

// import 'dart:convert';

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymshood/services/Helpers/saveCredentials.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'dart:developer' as developer;

import 'package:gymshood/services/Auth/auth_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';

class ServerProvider implements AuthProvider {
  final String? baseUrl = dotenv.env['BASE_URL'];
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;

  static final ServerProvider _instance = ServerProvider._internal();
  factory ServerProvider() => _instance;

  bool _initialized = false;

  ServerProvider._internal() {
    _dio = Dio();
  }

Dio get dio => _dio;
PersistCookieJar get cookieJar => _cookieJar;

  /// Initializes persistent cookies and attaches them to Dio
  @override
  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
    _dio.interceptors.add(CookieManager(_cookieJar));

    developer.log('✅ PersistCookieJar initialized at: ${dir.path}/.cookies/');
    developer.log('🛠️ ServerProvider initialized with persistent cookies');

    _initialized = true;
  }

  Future<String?> getCookieToken() async {
  final cookies = await _cookieJar.loadForRequest(Uri.parse(baseUrl!));

  for (var cookie in cookies) {
    if (cookie.name == 'token') {
      // developer.log('🍪 Found token: ${cookie.value}');
      return cookie.value;
    }
  }

  developer.log('⚠️ No token cookie found');
  return null;
}

  @override
  Future<String> register(String name, String email, String password, String role) async {
    try {
      final response = await _dio.post('$baseUrl/auth/register',
          data: {'name': name, 'email': email, 'password': password , 'role': role},
          options: Options(headers: {'Content-Type': 'application/json'}));
          saveRegistrationSessionId(response.data['registrationSessionId'].toString());
      // developer.log('aagaya idhar');
      if (response.statusCode == 200) {
        return "Successfull";
      } else {
        final message = response.data['message'];
        // developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return e.response?.data['message'] ?? 'Bad request';
      } else {
        developer.log('Dio error: ${e.message}');
        return 'Network error';
      }
    } catch (e) {
      return e.toString();
      // developer.log(e.toString());
    }
  }

  @override
  Future<void> sendverificationemail({required String email}) async {
    await _dio.post('$baseUrl/send-otp',
        data: {'email': email},
        options: Options(headers: {'Content-Type': 'application/json'}));
  }

  @override
  Future<String> verifyOTP({required String otp, required String email}) async {
    try {
      // developer.log('main aagaya');
      final prefs = await SharedPreferences.getInstance();
      final String? reg_id =  prefs.getString('registrationSessionId');
      final response = await _dio.post('$baseUrl/auth/verify-otp',
          data: {'otp': otp, 'email': email , "registrationSessionId": reg_id},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        return "Successfull";
      } else {
        final message = response.data['message'];
        // developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // developer.log('Error response: ${e.response?.data['message']}');

        return e.response?.data['message'] ?? 'Bad request';
      } else {
        // developer.log('Dio error: ${e.message}');
        return 'Network error';
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String> login(
      {required String email, required String password,required String role}) async {
    try {
      // developer.log('login pressed');
      final response = await _dio.post("$baseUrl/auth/login",
          data: {
            'email': email,
            'password': password,
            'role':role
          },
          options: Options(
              headers: {'Content-Type': 'application/json'},
              extra: {'withCredentials': true}));
      // developer.log('📬 Headers: ${response.headers}');
      // final cookies = await cookieJar.loadForRequest(Uri.parse(baseUrl));

      // cookies.forEach((cookie) {
      //   developer.log('🍪 Stored cookie: ${cookie.name}=${cookie.value}');
      // });
      if (response.statusCode == 200) {
        developer.log('Login successful');
        return "Successfull";
      } else {
        final message = response.data['message'];
        // developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return e.response?.data['message'] ?? 'Bad request';
      } else {
        developer.log('Dio error: ${e.message}');
        return 'Network error';
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String> googleLogIn({required token}) async {
    try {
      final response = await _dio.post("$baseUrl/auth/google-login",
          data: {
            'token': token,
            'role': "GymOwner"
          },
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        return "Successfull";
      } else {
        final message = response.data['message'];
        // developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return e.response?.data['message'] ?? 'Bad request';
      } else {
        developer.log('Dio error: ${e.message}');
        return 'Network error';
      }
    } catch (e) {
      return e.toString();
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'] ,
    scopes: ['email', 'profile'],
  );
  @override
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return "user is null";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final token = googleAuth.idToken;
      developer.log('token: $token');
      if (token == null) {
        return "Failed to get ID Token";
      } else {
        final String response = await googleLogIn(token: token);
        // developer.log()
        return response;
      }
    } catch (error) {
      return "Google Sign-In error: $error";
    }
  }

  @override
  Future<String> logOut() async {
    final response = await _dio.get(
      '$baseUrl/auth/logout',
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true},
      ),
    );
    if (response.statusCode == 200) {
      return 'Successfull';
    } else {
      return response.data['message'];
    }
  }

  @override
  Future<Authuser?> getUser() async {
    try {
      // final cookies = await cookieJar.loadForRequest(Uri.parse(baseUrl));
      // developer.log('➡️ Will send cookies: $cookies');
        final cookies = await _cookieJar.loadForRequest(Uri.parse('$baseUrl/user'));
  // developer.log('🍪 Loaded cookies: $cookies');

      final response = await _dio.get('$baseUrl/auth/profile',
          options: Options(
            headers: {'Content-Type': 'application/json'},
            extra: {'withCredentials': true},
          ));
      final user = response.data['user'];
      final Authuser authuser = Authuser.fromJson(user);
      return authuser;
    } on DioException catch (e) {
      if (e.response != null) {
        developer.log('Error response: ${e.response?.data}');
        return null;
      } else {
        developer.log('Dio error: ${e.message}');
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> forgotPassword({required String? email}) async {
    final response =
        await _dio.post('$baseUrl/auth/password/forgot', data: {'email': email},
              options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true},
      ),
        );
        developer.log('forgot');
    if (response.statusCode == 200) {
      return 'Successfull';
    } else {
      return response.data['message'];
    }
  }

 @override
  Future<String> resetPassword({
  required String token,
  required String password,
  required String confirmPassword,
}) async {
  try {
    final response = await _dio.put(
      '$baseUrl/auth/password/reset/$token',
      data: {
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      return 'Successfull';
    } else {
      return response.data['message'] ?? 'Unknown error occurred.';
    }
  } on DioException catch (e) {
    if (e.response != null && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

  @override
  Future<String> updatePassword(
      {required String newPassword, required String confirmPassword}) async {
    final response = await _dio.put('$baseUrl/auth/update-password',
        data: {'newPassword': newPassword, 'confirmPassword': confirmPassword});
    if (response.statusCode == 200) {
      return 'Successfull';
    } else {
      return response.data['message'];
    }
  }
}
