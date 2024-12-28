import 'package:fit_now/constants.dart';
import 'package:flutter/material.dart';

class UnderPart extends StatelessWidget {
  const UnderPart(
      {Key? key,
      required this.title,
      required this.navigatorText,
      required this.onTap})
      : super(key: key);
  final String title;
  final String navigatorText;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'ReadexPro-Medium',
            fontSize: 13,
            color: blue,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        TextButton(
          onPressed: (){
            onTap();
          },
          child: Text(
            navigatorText,
            style: TextStyle(
              color: orange,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'ReadexPro-Medium'
            ),
          )
        ),
      ],
    );
  }
}
