import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/sevices/Auth/auth_provider.dart';
// import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'package:gymshood/sevices/Auth/server_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateSplashScreen()){

   on<AuthEventRegister>((event, emit) async {
  developer.log('📥 AuthEventRegister received');

  final String email = event.email;
  final String password = event.password;
  final String name = event.name;

  try {
    final response = await provider.register(name, email, password);
    developer.log('📨 Response from provider: $response');

    if (response == "Successfull") {
      // developer.log('✅ Registration successful');
      emit(AuthStateNeedsVerification(email));
    } else {
      emit(AuthStateRegistering(error: response));
    }
  } catch (e) {
    // developer.log('❌ Error: ${e.toString()}');
    emit(AuthStateRegistering(error: 'Unexpected error occurred'));
  }
});

on<AuthEventInitialize>((event, emit) async {
  developer.log("✅ AuthEventInitialize triggered");
  try {
    final user = await provider.getUser();
    if(user!=null){
      developer.log("User: ${user.name}");
    emit(AuthStateLoggedIn());
    }else{
      developer.log(' ❌ user is null');
      emit(AuthStateSplashScreen());
    }
  } catch (e, st) {
    developer.log("❌ Error in getUser: $e\n$st");
    emit(AuthStateSplashScreen()); // fallback
  }
});


    on<AuthEventVerifyOtp>((event, emit) async{
      final String otp = event.otp;
      final String email = event.email ;
       
      final response = await provider.verifyOTP(otp: otp, email: email);
     
      developer.log(response);
      if(response == "Successfull"){
        emit(AuthStateLoggedIn());
       }else{
        emit(AuthStateVerifyOtp(error: response));
        // emit(AuthStateErrors(error: response));
       }
    },);
    // on<AuthEventInitialize>((event, emit) async{
    //  final user = provider.getUser();
    //  if(user)
    // },);
    on<AuthEventLogIn>((event, emit) async{
      final String email = event.email;
      final String password = event.password;
      developer.log('called');
      final String response = 
      await provider.
      login(email: email, password: password);
      
      if(response == 'Successfull'){
        emit(AuthStateLoggedIn());
      }else{
        developer.log(response);
        emit(AuthStateLoggedOut(error: response));
      }
    },);

    on<AuthEventGoogleLogIn>((event, emit) async {
      final String message = await provider.signInWithGoogle();
      if(message == 'Successfull'
      ){
        emit(AuthStateLoggedIn());
      }else{
        emit(AuthStateLoggedOut(error: message));
      }
    },);

    on<AuthEventLogOut>((event, emit)async {
       final String response = await provider.logOut();
       if(response == 'Successfull'){
        emit(AuthStateLoggedOut(error: null));
       }
       else{
        emit(AuthStateErrors(error: "some error occured"));
       }
    },);
    on<AutheventFirstScreen>((event, emit) {
      emit(AuthStateFIrst());
    },);
    on<Autheventjustgotologin>((event, emit) {
      emit(AuthStateLoggedOut(error: null));
    },);
    on<Autheventjustgotosignup>((event, emit) {
      emit(AuthStateRegistering(error:null));
    },);
    on<AuthEventUpdatePassword>((event, emit) async{
      final String pwd = event.password;
      final String cpwd = event.confirmPassword;

      final String response = await provider.updatePassword(
        newPassword: pwd, confirmPassword: cpwd);
        if(response=='Successfull'){
            emit(AuthStateLoggedOut(error: null));
        }
        else{
            emit(AuthStateErrors(error: "Cannot update your password"));
        }
    },
    
    );

  }

  
    
}