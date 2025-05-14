
// import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'dart:developer' as developer;

// import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';




class ServerProvider {
    final String baseUrl ='http://10.0.2.2:3000/api/v1/user';
    final Dio _dio = Dio();
    final cookieJar = CookieJar();
    ServerProvider(){
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    Future<String> register( String name , String email , String password )
    async{

      try{
      
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name' : name,
          'email' : email,
          'password': password
        },
        options: Options(headers: {'Content-Type': 'application/json'})
      );
      if(response.statusCode == 200){
         
          return "Successfull";
      }
      else{
        final message = response.data['message'];
        developer.log(message);
        return message?.toString() ?? 'unknown error';
      }}on DioException catch(e){
          if (e.response != null) {
    developer.log('Error response: ${e.response?.data}');
    return e.response?.data['message'] ?? 'Bad request';
  } else {
    developer.log('Dio error: ${e.message}');
    return 'Network error';
  }
      }
      catch(e){
        return e.toString();
        // developer.log(e.toString());
      }
    }
 
    Future<void> sendverificationemail({required String email})async{
              await _dio.post(
                '$baseUrl/send-otp',
                data: {
                  'email':email
                },
                options: Options(
                  headers: {'Content-Type': 'application/json'}
                )
              );
    }

    Future<String> verifyOTP({required String otp , required String email})
    async{
      try{
      final response = await _dio.post(
        '$baseUrl/verify-otp',
        data: {'otp' : otp , 'email' : email},
        options: Options(headers: {'Content-Type': 'application/json'})
      );
    
      if(response.statusCode == 200){
        return "Successfull";
      }
      else{
        final message = response.data['message'];
        developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    }on DioException catch(e){
          if (e.response != null) {
    developer.log('Error response: ${e.response?.data}');
    return e.response?.data['message'] ?? 'Bad request';
  } else {
    developer.log('Dio error: ${e.message}');
    return 'Network error';
  }
    } catch(e){
      return e.toString();
    }

    }

    Future<String> login({required String email , required String password })async{
      try{
      final response = await _dio.post("$baseUrl/login" , data: {
        'email' : email,
        'password':password,
      }, 
      options: Options(headers: {'Content-Type': 'application/json'}));
      if(response.statusCode == 200){
       return "Succesfull";
      }else{
        final message = response.data['message'];
        developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    }on DioException catch(e){
          if (e.response != null) {
    developer.log('Error response: ${e.response?.data}');
    return e.response?.data['message'] ?? 'Bad request';
  } else {
    developer.log('Dio error: ${e.message}');
    return 'Network error';
  }
    } catch(e){
      return e.toString();
    }
    }



      Future<String> googleLogIn({required token})async{
        try{
      final response = await _dio.post("$baseUrl/google-login" ,
       data: {
       {'token' : token},
      },options: Options(
        headers: {
          'Content-Type':'application/json'
        }
      )
      );
      if(response.statusCode == 200){
        return "Successfull";
      }else{
        final message = response.data['message'];
        developer.log(message);
        return message?.toString() ?? 'unknown error';
      }
    }on DioException catch(e){
          if (e.response != null) {
    developer.log('Error response: ${e.response?.data}');
    return e.response?.data['message'] ?? 'Bad request';
  } else {
    developer.log('Dio error: ${e.message}');
    return 'Network error';
  }
    } catch(e){
      return e.toString();
    }
      }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

Future<String> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return "user is null";
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final token = googleAuth.idToken;

    if (token == null) {
      return "Failed to get ID Token";
    }else{
      final String response = await googleLogIn(token: token);
      return response;
    }
  } catch (error) {
    return "Google Sign-In error: $error";
  }
}

Future<String> logOut()async{
  final response = await _dio.post('/logOut',
   options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
  );
  if(response.statusCode==200){
    return 'Successfull';
  }else{
    return response.data['message'];
  }
}

Future<Authuser> getUser()async{
  final response = await _dio.get(
    '/profile',
    options: Options(headers: {'Content-Type': 'application/json'})
  );
final user = response.data['user'];
final Authuser authuser =   Authuser.fromJson(user);
return authuser;
}

Future<String> forgotPassword({required String? email})async{
  final response = await _dio.post(
    '$baseUrl/forgot-password',
    data: {
      'email' : email
    }
  );
  if(response.statusCode==200){
    return response.data['message'];
  }else{
    return 'An error Occurred';
  }
}

Future <String> resetPassword({required String token , required String password , required String confirmPassword})async{
  final response = await _dio.put(
    '$baseUrl/reset-password/$token',
    data:{
      'password' : password ,
      'confirmPassword' : confirmPassword
    }  );

    if(response.statusCode==200){
    return 'Successfull';
  }else{
    return response.data['message'];
  }

}

Future<String> updatePassword({required String newPassword , required String confirmPassword})async{
final response = await _dio.put(
  '/update-password',
  data: {
    'newPassword' : newPassword,
    'confirmPassword' : confirmPassword
  }
);
if(response.statusCode==200){
    return 'Successfull';
  }else{
    return response.data['message'];
  }
}


}