import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_now/components/page_title_bar.dart';
import 'package:fit_now/components/under_part.dart';
import 'package:fit_now/components/upside.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/login_screen.dart';
import 'package:fit_now/widgets/rounded_button.dart';
import 'package:fit_now/widgets/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  String email = '', password = '', name = '', confirm_pass = '';

  Future<void> register() async {
    if (password != null){
      try {
        if (password != confirm_pass){
          Fluttertoast.showToast(
            msg: 'Password didn\'t match',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
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
          final newUser = await firestore.collection('users').doc(userCredential.user!.uid).set({
            'email' : email,
            'name' : name,
            'date_of_birth' : null,
            'weight' : int.parse(_weightController.text),
            'height' : int.parse(_heightController.text)
          });

          Fluttertoast.showToast(
            msg: 'Register Success',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.green,
            fontSize: 14
          );
        }
      }
      on FirebaseAuthException catch (e){
        if (e.code == 'weak-password'){
          Fluttertoast.showToast(
            msg: 'Password is too weak',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14
          );
        }
        else if (e.code == 'email-already-in-use'){
          Fluttertoast.showToast(
            msg: 'Email already exists',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15),
                        iconButton(context),
                        SizedBox(height: 20),
                        Text(
                          'or use your email account',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Open Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600
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
                                      color: kPrimaryColor,
                                    ),
                                    hintText: 'Email',
                                    hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                    border: InputBorder.none
                                  ),
                                ),
                              ),
                              TextFieldContainer(
                                child: TextFormField(
                                  controller: _nameController,
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.person,
                                      color: kPrimaryColor,
                                    ),
                                    hintText: 'Name',
                                    hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                    border: InputBorder.none
                                  ),
                                ),
                              ),
                              TextFieldContainer(
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obsecureText,
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.lock,
                                      color: kPrimaryColor,
                                    ),
                                    hintText: "Password",
                                    hintStyle:  TextStyle(fontFamily: 'OpenSans'),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        setState(() {
                                          _obsecureText = !_obsecureText;
                                        });
                                      }, 
                                      icon: Icon(
                                        _obsecureText ? Icons.visibility_off : Icons.visibility,
                                        color: Color(0xff36454F),
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
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.lock,
                                      color: kPrimaryColor,
                                    ),
                                    hintText: "Confirm Password",
                                    hintStyle:  TextStyle(fontFamily: 'OpenSans'),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        setState(() {
                                          _obsecureTextConfPassword = !_obsecureTextConfPassword;
                                        });
                                      }, 
                                      icon: Icon(
                                        _obsecureTextConfPassword ? Icons.visibility_off : Icons.visibility,
                                        color: Color(0xff36454F),
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
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.calendar_month,
                                      color: kPrimaryColor,
                                    ),
                                    hintText: 'Date of Birth',
                                    hintStyle: const TextStyle(fontFamily: 'OpenSans'),
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      onPressed: (){}, 
                                      icon: Icon(Icons.calendar_month_outlined)
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
                                });
                                register();
                              }),
                              SizedBox(
                                height: 10,
                              ),
                              UnderPart(
                                title: "Already have an account?",
                                navigatorText: "Login Here", 
                                onTap: (){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              )
                            ],
                          )
                        ),
                        SizedBox(height: 80)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}