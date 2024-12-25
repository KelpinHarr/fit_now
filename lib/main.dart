import 'package:fit_now/config/config.dart';
import 'package:fit_now/ui/home.dart';
import 'package:fit_now/ui/login_screen.dart';
import 'package:fit_now/ui/register_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseInit();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register' : (context) => const RegisterPage(),
        '/home' : (context) => HomePage(
          email: ModalRoute.of(context)?.settings.arguments as String
        )
      },
    );
  }
}

