import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/chat.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReportPage extends StatefulWidget {
  final String email;
  const ReportPage({super.key, required this.email});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            title: Center(
              child: Text(
                  'Progress Tracking',
              
                  style: TextStyle(
                    color: orange,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w800,
                    
                  ),
                ),
            ),
            // ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
              ? MediaQuery.of(context).size.height
              : MediaQuery.of(context).size.height * 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 20),
                  child: Text(
                    "Monitor Your Progress, Set New Goald, and Keep Pushing Towards Your Best Self.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  )
                )
              ],
            ),
          ),
        ),
        ),
        floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ChatPage(email: widget.email)), 
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
        onTabSelected: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      )
      );
    }
  }