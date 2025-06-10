import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymshood/Themes/theme.dart';
import 'package:gymshood/pages/AuthPages/SignUpPage.dart';
import 'package:gymshood/pages/bottomNavigationPages/bottomNavigationBar.dart';
import 'package:gymshood/pages/AuthPages/resetPassword.dart';
import 'package:gymshood/pages/AuthPages/splashscreen.dart';
import 'package:gymshood/pages/AuthPages/verifyEmailview.dart';
import 'package:gymshood/services/Auth/auth_server_provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:gymshood/pages/AuthPages/firstScreen.dart';
import 'package:gymshood/pages/AuthPages/loginPage.dart';
import 'package:gymshood/pages/AuthPages/forgotPassword.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final serverProvider = ServerProvider();
  await serverProvider.init(); // ✅ Wait until cookie jar is restored

  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(serverProvider)..add(const AuthEventInitialize()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  String? _resetToken;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path.contains('resetpassword')) {
        final token = uri.queryParameters['id'];
        if (token != null) {
          setState(() {
            _resetToken = token;
          });
        }
      }
    }, onError: (err) {
      developer.log("Deep link error: $err");
    });
  }

  Future<void> _handleInitialLink() async {
    final uri = await getInitialUri();
    if (uri != null && uri.path.contains('resetpassword')) {
      final token = uri.queryParameters['id'];
      if (token != null) {
        setState(() {
          _resetToken = token;
        });
      }
    }
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GymsHood',
    theme: lightmode,
    home: _resetToken != null ? Resetpassword(token: _resetToken!) : const RootPage(),
  );
}
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      return _responseWidget(state);

     
    },
  );
}

}


Widget _responseWidget(AuthState state) {
  developer.log("🔁 Current AuthState: ${state.runtimeType}");
  if (state is AuthStateSplashScreen) {
    return const SplashScreen();
  } else if (state is AuthStateFIrst) {
    return const FirstScreen();
  } else if (state is AuthStateLoggedOut ) {
    return const LoginPage();
  } else if (state is AuthStateRegistering) {
    return const SignUpPage();
  } else if (state is AuthStateForgotPassword || state is AuthStateResetPassword) {
    return const ForgotPasswordView();
  } else if (state is AuthStateVerifyOtp || state is AuthStateNeedsVerification) {
    return const VerifyEmailView();
  } else if (state is AuthStateLoggedIn) {
    return const BottomNavigation();
  } else {
    return const Scaffold(
      body: Center(child: Text("Unknown state")),
    );
  }
}

bool _shouldAnimate(AuthState oldState, AuthState newState) {
  // Define transitions that should animate (customize as needed)
  const animatedStates = {
    AuthStateLoggedIn,
    AuthStateLoggedOut,
  };

  return animatedStates.contains(oldState.runtimeType) &&
         animatedStates.contains(newState.runtimeType);
}