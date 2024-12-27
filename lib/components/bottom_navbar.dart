import 'package:fit_now/ui/chat.dart';
import 'package:fit_now/ui/home.dart';
import 'package:fit_now/ui/workout.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final String email;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.email,
    this.selectedColor = Colors.orange,
    this.unselectedColor = Colors.white,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              _buildNavItem(Iconsax.home, 0, context),
              const SizedBox(width: 20),
              _buildNavItem(Iconsax.weight_1, 1, context),
            ],
          ),
          Row(
            children: [
              _buildNavItem(Iconsax.menu_board, 3, context),
              const SizedBox(width: 20),
              _buildNavItem(Iconsax.frame_1, 4, context),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: currentIndex == index ? selectedColor : unselectedColor,
      ),
      iconSize: 35,
      onPressed: () {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context)=> HomePage(email: email)), 
              (Route<dynamic> route) => false
            );
            break;
          
          case 1:
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context)=> WorkoutPage(email: email)), 
              (Route<dynamic> route) => false
            );
            break;

          default:
            onTabSelected(index);
        }
      },
    );
  }
}
