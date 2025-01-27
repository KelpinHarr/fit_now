import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/bloc/workout_bloc.dart';
import 'package:fit_now/models/Video.dart';
import 'package:fit_now/models/WatchedVideo.dart';
import 'package:fit_now/models/Workout.dart';
import 'package:fit_now/session_helper.dart';
import 'package:fit_now/ui/chat.dart';
import 'package:fit_now/ui/login_screen.dart';
import 'package:fit_now/ui/target_muscle_detail.dart';
import 'package:fit_now/ui/workout_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  // Changed class name to ProfilePage
  final String email;

  const ProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState(); // Changed state class name
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _birthday = '';
  int _weight = 0;
  int _height = 0;
  int _currentIndex = 4;
  int _ages = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final user = userDoc.docs.first;
        Timestamp dobUser = user['date_of_birth'];
        DateTime dob = dobUser.toDate();

        setState(() {
          _name = user['name'];
          _birthday = "${dob.day}/${dob.month}/${dob.year}";
          _weight = user['weight'];
          _height = user['height'];
          _ages = 2025 - dob.year;
        });
      }
    } catch (e) {
      // Handle error
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0E1D3A),
        title: Text('Profile', style: TextStyle(color: Color(0xFFF39C12))),
      ),
      body: Container(
        color: white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile_picture.jpg'),
              ),
              SizedBox(height: 20),
              Text(
                _name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                widget.email, // Display Email
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                "Birthday: $_birthday", // Display Birthday
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoCard('$_weight Kg', 'Weight'),
                  _buildInfoCard(
                      '$_ages', 'Years Old'), // Replace with actual age
                  _buildInfoCard('$_height CM', 'Height'),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                  // Logout button
                  onPressed: () async {
                    await SessionHelper.clearLoginStatus();
                    // await logoutFromGoogle();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E1D3A), // dark blue
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0)), // Rounded shape
                  ),
                  child: Row(
                    // Row to align icon and text
                    mainAxisSize: MainAxisSize.min, // Wrap content horizontally
                    children: [
                      Icon(Icons.logout, color: Colors.white), // Logout Icon
                      SizedBox(width: 8), // Spacing between icon and text
                      Text("Logout", style: TextStyle(color: Colors.white)),
                    ],
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 4;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(email: widget.email)),
            );
          },
          backgroundColor: darkBlue,
          child: Icon(
            Iconsax.messages_1,
            color: _currentIndex == 2 ? orange : white,
            size: 35,
          ),
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFF0E1D3A), // dark blue
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}
