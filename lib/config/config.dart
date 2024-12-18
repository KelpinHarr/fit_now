import 'package:firebase_core/firebase_core.dart';

Future<void> firebaseInit() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAN_hPP53hu0T_H-aRBJxse9XvXnQ57GSs", 
      appId: "1:539195871126:android:1745678f6752f13ad3d7b7", 
      messagingSenderId: "539195871126", 
      projectId: "fit-now-8788d",
      storageBucket: "fit-now-8788d.firebasestorage.app"
    )
  );
}