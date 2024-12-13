import 'package:fit_now/components/page_title_bar.dart';
import 'package:fit_now/components/under_part.dart';
import 'package:fit_now/components/upside.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/register_screen.dart';
import 'package:fit_now/ui/home_page.dart';
import 'package:fit_now/widgets/rounded_button.dart';
import 'package:fit_now/widgets/rounded_icon.dart';
import 'package:fit_now/widgets/rounded_input_field.dart';
import 'package:fit_now/widgets/rounded_password_field.dart';
import 'package:fit_now/widgets/text_field_container.dart';
import 'package:flutter/material.dart';


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

                const Upside(imgUrl: "assets/images/login.png"),
                const PageTitleBar(title: "Login to your account"),
                Padding(
                  padding: EdgeInsets.only(top: 320),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        iconButton(context),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "or use your email account",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'OpenSans',
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
                              switchListTile(),
                              RoundedButton(text: 'LOGIN', press: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                              }),
                              const SizedBox(
                                height: 10,
                              ),
                              UnderPart(
                                title: "Don't have an account?",
                                navigatorText: "Register here",
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterPage()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13
                                ),
                              ),
                              const SizedBox(height: 50,)
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
      ),
    );
  }

  Widget switchListTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 40),
      child: SwitchListTile(
        dense: true,
        title: const Text(
          'Remember Me',
          style: TextStyle(fontSize: 16, fontFamily: 'OpenSans'),
        ),
        value: _switchValue,
        activeColor: kPrimaryColor,
        onChanged: _isEnabled
            ? (val){
                setState(() {
                  _switchValue = val;
                });
              }
            : null,
      ),
    );
  }
}


iconButton(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      RoundedIcon(imageUrl: "assets/images/google.jpg"),
    ],
  );
}