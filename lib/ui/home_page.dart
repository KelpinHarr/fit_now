import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0EAF4),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeText(),
              const SizedBox(height: 20.0),
              _buildPreviousSessionSection(),
              const SizedBox(height: 30.0),
              _buildCallToAction(),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomNavigationBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Kelip!',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          'It\'s a new day to achieve new milestones.\nLet\'s get moving!',
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPreviousSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your previous session',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSessionCard('Vid utube'),
              const SizedBox(width: 10.0),
              _buildSessionCard('Vid utube'),
              const SizedBox(width: 10.0),
              _buildSessionCard('Vic'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(String title) {
    return Container(
      width: 100.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready for a workout designed just for you? Our AI can create custom plans based on your goals.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke layar pemilihan target muscle group
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Choose your target muscle group'),
                ),
              )),
        ],
      ),
    );
  }
  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipPath(
      clipper: BottomNavBarClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF22272e),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 30, color: Colors.orange),
                onPressed: () {
                  // Handle home
                },
              ),
              IconButton(
                icon: Icon(Icons.fitness_center, size: 30, color: Colors.orange),
                onPressed: () {
                  // Handle workout page
                },
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble, size: 30, color: Colors.orange),
                onPressed: () {
                  // Handle chat
                },
              ),
              IconButton(
                icon: Icon(Icons.calendar_today, size: 30, color: Colors.orange),
                onPressed: () {
                  // Handle history
                },
              ),
              IconButton(
                icon: Icon(Icons.person, size: 30, color: Color(Colors.orange)),
                onPressed: () {
                  // Handle user profile
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, size.height * 1.3, size.width, size.height );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}