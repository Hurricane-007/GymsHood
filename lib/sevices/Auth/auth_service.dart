import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'package:gymshood/sevices/Auth/auth_provider.dart';
import 'package:gymshood/sevices/Auth/server_provider.dart';

class AuthService implements AuthProvider{
  final AuthProvider provider;
  const AuthService({required this.provider});

  factory AuthService.server() => AuthService(provider: ServerProvider());

  @override
  Future<Authuser?> getUser() {
    return provider.getUser();
  }

  @override
  Future<String> googleLogIn({required token}) {
    return provider.googleLogIn(token: token);
  }

  @override
  Future<String> logOut() => provider.logOut();

  @override
  Future<String> login({required String email, required String password})=>
  provider.login(email: email, password: password);

  @override
  Future<String> register(String name, String email, String password) =>
  provider.register(name, email, password);

  @override
  Future<String> resetPassword({required String token,
   required String password, required String confirmPassword}) =>
   provider.resetPassword(token: token, password: password, confirmPassword: confirmPassword);

  @override
  Future<void> sendverificationemail({required String email}) => provider.sendverificationemail(email: email);

  @override
  Future<String> signInWithGoogle() => provider.signInWithGoogle();

  @override
  Future<String> updatePassword({required String newPassword, required String confirmPassword}) => provider.updatePassword(newPassword: newPassword, 
  confirmPassword: confirmPassword);

  @override
  Future<String> verifyOTP({required String otp, required String email}) => provider.verifyOTP(otp: otp, email: email);
  
  @override
  Future<void> init() {
   return provider.init();
  }
  
  @override
  Future<String> forgotPassword({required String email}) {
      return provider.forgotPassword(email: email);
  }

  
}