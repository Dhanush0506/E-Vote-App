import 'package:flutter/material.dart';
import 'package:votingapp/ballotScreen.dart';
import 'package:votingapp/otpscreen.dart';
import 'package:votingapp/profileScreen.dart';
import 'package:votingapp/resultScreen.dart';
import 'package:votingapp/welcome.dart';
import 'package:votingapp/loginscreen.dart';
import 'package:votingapp/splashscreen.dart';
import 'package:votingapp/homescreen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:votingapp/signupscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Vote',
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        'profile': (context) => ProfileScreen(),
        'result': (context) => ResultsScreen(),
        'ballot': (context) => BallotScreen(),
      },
    );
  }
}
