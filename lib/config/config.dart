import 'package:firebase_core/firebase_core.dart';

Future<void> firebaseInit() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(

    );
  }
}