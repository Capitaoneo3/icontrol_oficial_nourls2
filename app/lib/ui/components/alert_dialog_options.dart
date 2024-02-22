import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/brand.dart';
import '../../model/employee.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class OptionsAlertDialog extends StatefulWidget {
  OptionsAlertDialog({Key? key});

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<OptionsAlertDialog> createState() => _OptionsAlertDialog();
}

class _OptionsAlertDialog extends State<OptionsAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                Dimens.paddingApplication,
                Dimens.paddingApplication,
                Dimens.paddingApplication,
                MediaQuery.of(context).viewInsets.bottom +
                    Dimens.paddingApplication),
            child: Column(
              children: [
                SizedBox(height: Dimens.marginApplication),
                InkWell(
                  onTap: () {

                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/ui/fleets");

                  },
                  child: Row (children: [
                    Icon(Icons.fire_truck_outlined),
                    SizedBox(width: Dimens.minMarginApplication,),
                    Text(
                      "Frotas",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: Dimens.textSize6,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],)
                ),
                SizedBox(height: Dimens.minMarginApplication),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/ui/brands");
                  },
                  child: Row (children: [
                    Icon(Icons.shield_outlined),
                    SizedBox(width: Dimens.minMarginApplication,),
                    Text(
                      "Marcas",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: Dimens.textSize6,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],)
                ),
                SizedBox(height: Dimens.marginApplication),
                Styles().div_horizontal,
                SizedBox(height: Dimens.marginApplication),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize5,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
