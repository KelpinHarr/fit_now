import 'package:fit_now/bloc/workout_bloc.dart';
import 'package:fit_now/config/config.dart';
import 'package:fit_now/session_helper.dart';
import 'package:fit_now/ui/home.dart';
import 'package:fit_now/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseInit();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initApp(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        else if (snapshot.hasError){
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }
        else if (snapshot.hasData){
          bool isLoggedIn = snapshot.data!['isLoggedIn'] ?? false;
          // String userRole = snapshot.data!['userRole'] ?? "";
          String userName = snapshot.data!['userName'] ?? "";
          String userEmail = snapshot.data!['userEmail'] ?? "";

          Widget home;
          if (isLoggedIn){
            home = HomePage(email: userEmail);
          }
          else {
            home = LoginPage();
          }

          return MaterialApp(
            home: BlocProvider(
              create: (context) => WorkoutBloc(
                initialCheckboxStates: ModalRoute.of(context)?.settings.arguments as List<bool>, 
                email: userEmail
              ),
              child: home,
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Unexpected Error: No data found'),
              ),
            ),
          );
        }
      },
    );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   initialRoute: '/login',
    //   routes: {
    //     '/login': (context) => const LoginPage(),
    //     '/register' : (context) => const RegisterPage(),
    //     '/home' : (context) => HomePage(
    //       email: ModalRoute.of(context)?.settings.arguments as String
    //     )
    //   },
    // );
  }

  Future<Map<String, dynamic>> _initApp() async {
    bool isLoggedIn = await SessionHelper.getLoginStatus();
    bool isLoginExpired = await SessionHelper.isLoginExpired();
    String? userName = await SessionHelper.getUserName();
    String? userEmail = await SessionHelper.getUserEmail();

    if (isLoginExpired){
      await SessionHelper.clearLoginStatus();
      isLoggedIn = false;
    }

    return {
      'isLoggedIn': isLoggedIn,
      'userName': userName,
      'userEmail': userEmail
    };
  }
}

