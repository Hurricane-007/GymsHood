import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gymshood/sevices/Auth/AuthUser.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'package:gymshood/sevices/Auth/server_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(ServerProvider provider) : super(const AuthStateNeedsVerification()){

    on<AuthEventRegister>((event,emit)async{
        
        final String email = event.email;
        final String password = event.password;
        final String name = event.name;

      final  response = await provider.register(name, email, password);
       if(response == "Successfull"){
        emit(AuthStateNeedsVerification());
       }else{
        emit(AuthStateRegistering(error: response));
       }
    });

    on<AuthEventInitialize>((event, emit) async{
      final user = await provider.getUser();
      final String? name = user.name;
      emit(AuthStateSplashScreen());
      if(name == null){
        emit(AuthStateSplashScreen());
      }else{
        emit(AuthStateLoggedIn());
      }
    },);

    on<AuthEventVerifyOtp>((event, emit) async{
      final String otp = event.otp;
      final String email = event.email ;
      final String response = await provider.verifyOTP(otp: otp, email: email);
      if(response == "Successfull"){
        emit(AuthStateLoggedOut(error: null));
       }else{
        emit(AuthStateVerifyOtp(error: response));
       }
    },);
    // on<AuthEventInitialize>((event, emit) async{
    //  final user = provider.getUser();
    //  if(user)
    // },);
    on<AuthEventLogIn>((event, emit) async{
      final String email = event.email;
      final String password = event.password;
      final String response = 
      await provider.
      login(email: email, password: password);
      if(response == 'Successfull'){
        emit(AuthStateLoggedIn());
      }else{
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
    },);
  }

  
    
}