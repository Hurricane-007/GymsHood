
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'dart:developer' as developer;




class ServerProvider {
    final String baseUrl = 'http://192.168.79.37:3000/api/v1/user';
    final Dio _dio = Dio();
    final cookieJar = CookieJar();
    ServerProvider(){
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    Future<void> register ( String name , String email , String password )
    async{
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name' : name,
          'email' : email,
          'password': password
        }
      );
      if(response.statusCode == 200){
          developer.log("registered successfully");
      }
      else{
        developer.log("cannot be registered");
      }
    }

    Future<void> verifyOTP({required String otp})async{
      final response = await _dio.post(
        '$baseUrl/verify-otp',
        data: {'otp' : otp}
      );
      if(response.statusCode == 200){
        developer.log("Account verified Succesfully");
      }
      else if(response.statusCode == 404){
        developer.log("Invalid Otp");
      }
      else if(response.statusCode == 400){
        developer.log("Otp Expired");
      }
    }

    Future<void> login({required String email , required String password })async{
      final response = await _dio.post("$baseUrl/login" , data: {
        'email' : email,
        'password':password,
      });
      if(response.statusCode == 200){
        developer.log("User loggined succesfully");
      }
      else if(response.statusCode == 400){
        developer.log("Invalid Email or password");
      }
    }



        Future<void> googleLogIn({required token})async{
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
        developer.log("User loggined succesfully");
      }else{
        developer.log("some error occurred");
      }
    }
    

    final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      developer.log("Sign in aborted by user");
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final token = googleAuth.idToken;

    if (token == null) {
      developer.log("Failed to get ID Token");
      return;
    }else{
      await googleLogIn(token: token);
    }

    
  } catch (error) {
    developer.log("Google Sign-In error: $error");
  }
}

Future<void> logOut()async{
  final response = await _dio.post('/logOut',
   options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
  );
  if(response.statusCode==200){
    developer.log("Logged Out succesfully");
  }
}

Future<Authuser> getUser()async{
  final response = await _dio.post(
    '/profile',
    options: Options(headers: {'Content-Type': 'application/json'})
  );
  final user = response.data['user'];
final Authuser authuser =   Authuser.fromJson(user);
return authuser;
}

Future<String> forgotPassword({required String email})async{
  final response = await _dio.post(
    '$baseUrl/forgot-password',
    data: {
      'email' : email
    }
  );
  return response.data['message'];
}

Future <String> resetPassword({required String token , required String password , required String confirmPassword})async{
  final response = await _dio.put(
    '$baseUrl/reset-password/$token',
    data:{
      'password' : password ,
      'confirmPassword' : confirmPassword
    }  );

    return response.data['message'];

}

Future<String> updatePassword({required String newPassword , required String confirmPassword})async{
final response = await _dio.put(
  '/update-password',
  data: {
    'newPassword' : newPassword,
    'confirmPassword' : confirmPassword
  }
);

return response.data['message'];
}


}