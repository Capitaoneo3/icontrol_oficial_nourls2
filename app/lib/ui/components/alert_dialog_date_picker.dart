import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../res/dimens.dart';
import '../../res/owner_colors.dart';

class DatePickerAlertDialog extends StatefulWidget {
  Container? btnConfirm;
  TextEditingController dateController;

  DatePickerAlertDialog({
    Key? key,
    this.btnConfirm,
    required this.dateController
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<DatePickerAlertDialog> createState() => _DatePickerAlertDialogState();
}

class _DatePickerAlertDialogState extends State<DatePickerAlertDialog> {

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    widget.dateController.text = date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString();


    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimens.paddingApplication),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: date,
                    onDateTimeChanged: (DateTime newDateTime) {

                      widget.dateController.text = newDateTime.day.toString() + "/" + newDateTime.month.toString() + "/" + newDateTime.year.toString();

                    },
                  ),
                ),

                widget.btnConfirm!
              ],
            ),
          ),
        ]);
  }
}
