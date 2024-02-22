import 'package:flutter/material.dart';

import '../../res/dimens.dart';

class GenericAlertDialog extends StatefulWidget {
  String? title;
  String? content;
  TextButton? btnBack;
  TextButton? btnConfirm;

  GenericAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.btnBack,
    this.btnConfirm,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<GenericAlertDialog> createState() => _GenericAlertDialogState();
}

class _GenericAlertDialogState extends State<GenericAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimens.paddingApplication),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title!,
                  style: TextStyle(
                      fontSize: Dimens.textSize7,
                      fontFamily: 'Inter',
                      color: Colors.black),
                ),
                SizedBox(height: Dimens.marginApplication),
                Text(
                  widget.content!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Dimens.textSize5,
                      fontFamily: 'Inter',
                      color: Colors.black),
                ),
                SizedBox(height: Dimens.marginApplication),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [widget.btnBack!, widget.btnConfirm!],
                )
              ],
            ),
          ),
        ]);
  }
}
