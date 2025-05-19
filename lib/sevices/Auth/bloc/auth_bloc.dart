// import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/sevices/Auth/auth_provider.dart';
// import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
// import 'package:gymshood/sevices/Auth/server_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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
    
    // developer.log(user.toString());
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


    on<AuthEventLogIn>((event, emit) async{
      final String email = event.email;
      final String password = event.password;
      // developer.log('called');
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
       developer.log('call recieved');
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
    on<AuthEventjustgotoHome>((event, emit) {
      emit(AuthStateLoggedIn());
    },);
    on<Autheventjustgotologin>((event, emit) {
      emit(AuthStateLoggedOut(error: null));
    },);
    on<Autheventjustgotosignup>((event, emit) {
      emit(AuthStateRegistering(error:null));
    },);

        on<AuthEventForgotPassword>((event, emit) async{
      try{
        final email = event.email!;
        final String response = 
        await provider.forgotPassword(email:email);
        if(response=='Successfull'){
          developer.log("Successfull");
          // showInfoDialog(context, "Email 📩 has been sent to you. open your Mailbox to reset password");
          emit(AuthStateLoggedOut(error: null));
        }else{
          developer.log(response);
          emit(AuthStateForgotPassword(error: response , hasSendEmail: false));
        }


      }catch(e){
        developer.log(e.toString());
      }
    },);

    on<AuthEventResetPassword>((event, emit) async{

      String pwd = event.password;
      String confirmpwd = event.confirmPassword;
      String token = event.token;
      final String response = await provider.resetPassword(token: token, password: pwd, confirmPassword: confirmpwd);
      if(response == 'Successfull'){
        developer.log('✅ Reset Password successful');
          emit(AuthStateLoggedOut(error: "password reset successfully. Please log in again"));
      }else{

        emit(AuthStateResetPassword(error: response));
      }
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