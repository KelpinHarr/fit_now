  import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Please wait..."),
              ),
            ],
          ),
        );
      },
    );
  }