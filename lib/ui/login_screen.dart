import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_now/components/page_title_bar.dart';
import 'package:fit_now/components/under_part.dart';
import 'package:fit_now/components/upside.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/controller/dialog_controller.dart';
import 'package:fit_now/session_helper.dart';
import 'package:fit_now/ui/home.dart';
import 'package:fit_now/ui/register_screen.dart';
import 'package:fit_now/widgets/rounded_button.dart';
import 'package:fit_now/widgets/rounded_icon.dart';
import 'package:fit_now/widgets/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _switchValue = false;
  bool _isEnabled = true;
  bool _obsecureText = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  String email = '', password = '', _name = '';

  Future<void> login() async {
    if (_formKey.currentState!.validate()){
      setState(() {
        email = _emailController.text;
        password = _passwordController.text;
      });

      try {
        showLoadingDialog(context);
        final auth = FirebaseAuth.instance;
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, 
          password: password
        );

        final firestore = FirebaseFirestore.instance;
        final userDocs = await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userDocs.docs.isNotEmpty){
          final users = userDocs.docs.first;
          final name = users['name'];

          if (_switchValue || _isEnabled){
            await SessionHelper.setLoginStatus(name, email);
          }

          setState(() {
            _name = name;
          });

          Navigator.of(context).pop();
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => HomePage(email: email))
          );
        }
      }
      on FirebaseAuthException catch (e){
        String message;
        if (e.code == 'user-not-found'){
          message = 'User not found';
        }
        else if (e.code == 'invalid-credential'){
          message = 'User not found';
        }
        else if (e.code == 'wrong-password'){
          message = 'Wrong Password';
        }
        else {
          message = 'An error occured. Please try again.';
        }

        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.orange,
          fontSize: 14
        );
      }
      catch (e){
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: 'Error :$e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.orange,
          fontSize: 14
        );
      }
    }
  }

  void _showDialog() async {
    final TextEditingController _emailDialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password', style: TextStyle(fontFamily: 'ReadexPro-Medium'),),
          backgroundColor: white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email address to reset your password.', style: TextStyle(fontFamily: 'ReadexPro-Medium'),),
              SizedBox(height: 10),
              TextFieldContainer(
                child: TextFormField(
                  controller: _emailDialogController,
                  cursorColor: orange,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.email,
                      color: orange,
                    ),
                    hintText: 'Email',
                    hintStyle: const TextStyle(fontFamily: 'ReadexPro-Medium'),
                    border: InputBorder.none
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: blue
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = _emailDialogController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _resetPassword(email);
                } 
                else {
                  Fluttertoast.showToast(
                    msg: 'Please enter a valid email address.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                }
              },
              child: Text(
                'Send',
                style: TextStyle(
                  color: white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> loginWithGoogle() async {
    showLoadingDialog(context);
    try {
      final _auth = FirebaseAuth.instance;
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null){
          Navigator.pop(context);
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => HomePage(email: user.email!, name: user.displayName,))
          );
      }
    } 
    on FirebaseAuthException catch (e){
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Error :$e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: 'Email has been sent',
        toastLength: Toast.LENGTH_LONG,
        textColor: white,
        backgroundColor: Colors.green
      );
    }
    on FirebaseAuthException catch (e){
      Fluttertoast.showToast(
        msg: 'Error :$e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              const Upside(imgUrl: "assets/images/login.png"),
              const PageTitleBar(title: "Login to your account"),
              Padding(
                padding: EdgeInsets.only(top: 320),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      iconButton(context, loginWithGoogle),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "or use your email account",
                        style: TextStyle(
                          color: blue,
                          fontFamily: 'ReadexPro-Medium',
                          fontSize: 13,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _emailController,
                                cursorColor: orange,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.email,
                                    color: orange,
                                  ),
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(fontFamily: 'ReadexPro-Medium'),
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obsecureText,
                                cursorColor: orange,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: orange,
                                  ),
                                  hintText: "Password",
                                  contentPadding: EdgeInsets.only(top: 10),
                                  hintStyle:  TextStyle(fontFamily: 'ReadexPro-Medium'),
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _obsecureText = !_obsecureText;
                                      });
                                    }, 
                                    icon: Icon(
                                      _obsecureText ? Icons.visibility_off : Icons.visibility,
                                      color: orange,
                                    )
                                  ),
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            switchListTile(),
                            RoundedButton(text: 'LOGIN', press: login),
                            const SizedBox(
                              height: 10,
                            ),
                            // UnderPart(
                            //   title: "Don't have an account?",
                            //   navigatorText: "Register here",
                            //   onTap: () {
                            //     Navigator.pushNamedAndRemoveUntil(
                            //       context,
                            //       '/register',
                            //       (Route<dynamic> route) => false,
                            //     );
                            //   },
                            // ),
                            UnderPart(
                              title: "Don't have an account?",
                              navigatorText: "Register here",
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                                    transitionDuration: const Duration(milliseconds: 1200),
                                    reverseTransitionDuration: const Duration(milliseconds: 1200),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeThroughTransition(
                                        animation: animation,
                                        secondaryAnimation: secondaryAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                            TextButton(
                              onPressed: _showDialog, 
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: orange,
                                  fontFamily: 'ReadexPro-Medium',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13
                                ),
                              ),
                            ),
                            const SizedBox(height: 50)
                          ],
                        ),
                      )
                    ]
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Widget switchListTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 40),
      child: SwitchListTile(
        dense: true,
        title: const Text(
          'Remember Me',
          style: TextStyle(fontSize: 16, fontFamily: 'ReadexPro-Medium'),
        ),
        value: _switchValue,
        activeColor: Color(0xFF4B4A48),
        onChanged: _isEnabled
            ? (val){
                print('Value: $val');
                setState(() {
                  _switchValue = val;
                });
              }
            : null,
      ),
    );
  }
}

iconButton(BuildContext context, Function()? login) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      RoundedIcon(imageUrl: "assets/images/google.jpg", press: login),
    ],
  );
}
