import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_now/components/page_title_bar.dart';
import 'package:fit_now/components/under_part.dart';
import 'package:fit_now/components/upside.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/controller/dialog_controller.dart';
import 'package:fit_now/controller/user_controller.dart';
import 'package:fit_now/ui/home.dart';
import 'package:fit_now/ui/login_screen.dart';
import 'package:fit_now/widgets/rounded_button.dart';
import 'package:fit_now/widgets/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true;
  bool _obsecureTextConfPassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  DateTime? _selectedDate;

  String email = '', password = '', name = '', confirm_pass = '';

  Future<void> _selectDate() async {
    DateTime? _selected = await showDatePicker(
      context: context, 
      firstDate: DateTime(1800), 
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (_selected != null) {
      setState(() {
        _dateController.text = '${_selected.day} ${getMonthName(_selected.month)} ${_selected.year}';
        _selectedDate = _selected;
        // _loadLeaveRequests();
      });
    }
  }

  Future<void> register() async {
    showLoadingDialog(context);
    if (password != '' || email != '' || password != '' || name != '' || confirm_pass != ''){
      try {
        if (password != confirm_pass){
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: 'Password didn\'t match',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14
          );
        }
        else {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, 
            password: password
          );

          final firestore = FirebaseFirestore.instance;
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'email' : email,
            'name' : name,
            'date_of_birth' : _selectedDate,
            'weight' : int.parse(_weightController.text),
            'height' : int.parse(_heightController.text)
          });

          Navigator.of(context).pop();

          Fluttertoast.showToast(
            msg: 'Register Success',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.green,
            fontSize: 14
          );

          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/login', 
            (Route<dynamic> route) => false
          );
        }
      }
      on FirebaseAuthException catch (e){
        Navigator.of(context).pop();
        if (e.code == 'weak-password'){
          Fluttertoast.showToast(
            msg: 'Password is too weak',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14
          );
        }
        else if (e.code == 'email-already-in-use'){
          Fluttertoast.showToast(
            msg: 'Email already exists',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14
          );
        }
      }
    }
    else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Please complete all fields before continue',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
  }

  Future<void> loginWithGoogle() async {
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
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => HomePage(email: user.email!))
          );
      }
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
              const Upside(
                imgUrl: "assets/images/register.png"
              ),
              const PageTitleBar(title: 'Create New Account'),
              Padding(
                padding: const EdgeInsets.only(top: 320),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      iconButton(context, loginWithGoogle),
                      SizedBox(height: 20),
                      Text(
                        'or use your email account',
                        style: TextStyle(
                          color: blue,
                          fontFamily: 'Open Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _emailController,
                                cursorColor: kPrimaryColor,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.email,
                                    color: orange,
                                  ),
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                  contentPadding: EdgeInsets.only(top: 0),
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _nameController,
                                cursorColor: orange,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.person,
                                    color: orange,
                                  ),
                                  hintText: 'Name',
                                  contentPadding: EdgeInsets.only(top: 1),
                                  hintStyle: const TextStyle(fontFamily: 'OpenSans'),
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
                                  contentPadding: EdgeInsets.only(top: 11),
                                  hintStyle:  TextStyle(fontFamily: 'OpenSans'),
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
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obsecureTextConfPassword,
                                cursorColor: orange,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock_outline,
                                    color: orange,
                                  ),
                                  hintText: "Confirm Password",
                                  hintStyle:  TextStyle(fontFamily: 'OpenSans'),
                                  contentPadding: EdgeInsets.only(top: 11),
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _obsecureTextConfPassword = !_obsecureTextConfPassword;
                                      });
                                    }, 
                                    icon: Icon(
                                      _obsecureTextConfPassword ? Icons.visibility_off : Icons.visibility,
                                      color: orange,
                                    )
                                  ),
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                cursorColor: orange,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: orange,
                                  ),
                                  hintText: 'Date of Birth',
                                  contentPadding: EdgeInsets.only(top: 11),
                                  hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    onPressed: _selectDate, 
                                    icon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: orange,
                                    )
                                  )
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: TextFieldContainer(
                                    child: TextFormField(
                                      controller: _weightController,
                                      cursorColor: kPrimaryColor,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Weight',
                                        hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: TextFieldContainer(
                                    child: TextFormField(
                                      controller: _heightController,
                                      cursorColor: kPrimaryColor,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Height',
                                        hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            RoundedButton(text: 'REGISTER', press: (){
                              setState(() {
                                name = _nameController.text;
                                email = _emailController.text;
                                password = _passwordController.text;
                                confirm_pass = _confirmPasswordController.text;
                              });
                              register();
                            }),
                            SizedBox(
                              height: 10,
                            ),
                            // UnderPart(
                            //   title: "Already have an account?",
                            //   navigatorText: "Login Here", 
                            //   onTap: (){
                            //     Navigator.pushNamedAndRemoveUntil(
                            //       context,
                            //       '/login',
                            //       (Route<dynamic> route) => false,
                            //     );
                            //   }
                            // )
                            UnderPart(
                              title: "Already have an account?",
                              navigatorText: "Login here",
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
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
                          ],
                        )
                      ),
                      SizedBox(height: 30)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}