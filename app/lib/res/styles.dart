import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:icontrol/res/strings.dart';

import 'dimens.dart';
import 'owner_colors.dart';

class Styles {

  var styleDefaultButton = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
        EdgeInsets.all(Dimens.buttonPaddingApplication)),
    backgroundColor: MaterialStateProperty.all(OwnerColors.colorPrimary),
  );

  var styleAlternativeButton = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
        EdgeInsets.all(Dimens.buttonPaddingApplication)),
    backgroundColor: MaterialStateProperty.all(Colors.black),
  );

  var styleDefaultTextButton = TextStyle(
      fontFamily: 'Inter',
      fontSize: Dimens.textSize7,
      color: Colors.white);

  var styleTitleText = TextStyle(
    fontFamily: 'Inter',
    fontSize: Dimens.textSize8,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  var styleShapeBottomSheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(Dimens.minRadiusApplication),
    ),
  );

  var styleDescriptionText = TextStyle(
    fontFamily: 'Inter',
    fontSize: Dimens.textSize6,
    color: Colors.black,
  );

  var div_horizontal = Divider(
    color: Colors.black12,
    height: 2,
    thickness: 1.5,
  );

  var div_vertical = VerticalDivider(
    color: Colors.black12,
    width: 2,
    thickness: 1.5,
  );

  var defaultLoading = Center(child: CircularProgressIndicator());

  var defaultErrorRequest = Text(Strings.no_connection_description);
}
