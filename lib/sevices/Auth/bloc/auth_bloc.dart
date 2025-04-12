




import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/sevices/Auth/auth_provider.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent , AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateNeedsVerification()){
    
    on<AuthEventShouldRegister>((event, emit) {
     emit(const AuthStateRegistering(exception: null));
   },);

     on<AuthEventForgotPassword>((event, emit) async{
      emit(const AuthStateForgotPassword( exception: null, hasSendEmail: false));
      final email = event.email;
      if(email == null) return;//user wants to go to forgot password screen
      emit(const AuthStateForgotPassword( exception: null, hasSendEmail: true));
      bool didSend;
      Exception? exception;
      try{
        await provider.sendPasswordReset(toEmail: email);
        didSend = true;
        exception = null;
      }on Exception catch(e){
        didSend = false;
        exception=e;
      }
      emit( AuthStateForgotPassword( exception: exception, hasSendEmail: didSend));

    },);

    on<AuthEventLogIn>((event, emit) async{
      emit(const AuthStateLoggedOut(exception: null));
      final email = event.email;
      final password = event.password;
      
      try{
        final user = await provider.logIn(email: email, password: password);
        if(!user!.isEmailVerified){
          emit(AuthStateLoggedOut(exception: null));
          emit(AuthStateNeedsVerification());

        }
        else{
            emit(const AuthStateLoggedOut(exception: null));
            emit(AuthStateLoggedIn(user: user));
        } 
      }on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e));
      }
    },);

    on<AuthEventLogOut>((event, emit) async{
      try{
        await provider.logOut();
        
        emit( AuthStateLoggedOut(exception: null));
      }on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e));
      }
    },);

    on<AuthEventRegister>((event, emit) async{
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e));
      }
    },);

    on<AuthEventInitialize>((event, emit) async{
     await provider.initialize();
     final user = provider.currentUser;
     if(user==null){
      emit(
        const AuthStateSplashScreen(),
      );
     }
     else if(!user.isEmailVerified){
        emit(const AuthStateNeedsVerification());
     }else{
      emit(AuthStateLoggedIn(user:user));
     }
    },);

    on<AuthEventSendEmailVerification>((event, emit) async{
        await provider.sendEmailVerification();
        emit(state);
    },);

    on<AuthEventFirstScreen>((event, emit) {
      emit(AuthStateFirstScreen());
    },);

    on<AuthEventGoogleLogIn>((event, emit) async{
      final exception = event.exception;
      emit(AuthStateGoogleLoggedIn(exception));
    },);
  }
}

