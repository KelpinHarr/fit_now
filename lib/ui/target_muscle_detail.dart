import 'package:fit_now/constants.dart';
import 'package:fit_now/models/Workout.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TargetMuscleDetailPage extends StatelessWidget {
  final Workout workout;
  const TargetMuscleDetailPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    String mainInstruction = '';
    String tipSection = '';
    String variationsSection = '';

    try {
      String instructions = workout.instructions;

      if (instructions.contains('Tip:') && instructions.contains('Variations:')) {
        List<String> firstSplit = instructions.split('Tip:');
        mainInstruction = firstSplit[0].trim();
        
        List<String> secondSplit = firstSplit[1].split('Variations:');
        tipSection = 'Tip: ${secondSplit[0].trim()}';
        variationsSection = 'Variations: ${secondSplit[1].trim()}';
      } 
      else if (instructions.contains('Tip:') && !instructions.contains('Variations:')) {
        List<String> parts = instructions.split('Tip:');
        mainInstruction = parts[0].trim();
        tipSection = 'Tip: ${parts[1].trim()}';
      }
      else if (!instructions.contains('Tip:') && instructions.contains('Variations:')) {
        List<String> parts = instructions.split('Variations:');
        mainInstruction = parts[0].trim();
        variationsSection = 'Variations: ${parts[1].trim()}';
      }
      else {
        mainInstruction = instructions;
      }
    } catch (e) {
      mainInstruction = workout.instructions;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              icon: Icon(
                Iconsax.arrow_left_2,
                color: white,
              )
            ),
            title: Text(
              'Workout Detail',
              style: TextStyle(
                color: orange,
                fontFamily: 'ReadexPro-Medium',
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${workout.name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'Difficulty : ${workout.difficulty}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Equipment : ${workout.equipment}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Type : ${workout.type}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Muscle : ${workout.muscle}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Instructions : ',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$mainInstruction',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$tipSection',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$variationsSection',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.w600
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