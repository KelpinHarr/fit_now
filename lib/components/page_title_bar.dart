import 'package:fit_now/constants.dart';
import 'package:flutter/material.dart';

class PageTitleBar extends StatelessWidget {
  const PageTitleBar({ Key? key,required this.title }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 260.0),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 4,
        decoration: const BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:16.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ReadexPro-Medium',
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: white
            ),
          ),
        ),
      ),
    );
  }
}