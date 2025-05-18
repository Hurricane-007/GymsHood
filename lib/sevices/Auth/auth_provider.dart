import 'package:gymshood/sevices/Auth/AuthUser.dart';

abstract class AuthProvider {
  Future<void> init();
  Future<String> register(String name, String email, String password);
  Future<void> sendverificationemail({required String email});
  Future<String> verifyOTP({required String otp, required String email});
  Future<String> login({required String email, required String password});
  Future<String> googleLogIn({required token});
  Future<String> signInWithGoogle();
  Future<String> logOut();
  Future<Authuser?> getUser();
  Future<String> forgotPassword({required String email});
  Future<String> resetPassword(
      {required String token,
      required String password,
      required String confirmPassword});
  Future<String> updatePassword(
      {required String newPassword, required String confirmPassword});
}
