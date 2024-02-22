import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApplicationMessages {
  BuildContext context;

  ApplicationMessages({Key? key, required this.context});

  void showMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
