import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icontrol/config/preferences.dart';

import '../../res/dimens.dart';
import '../../res/owner_colors.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () async {

      await Preferences.init();

      if (await Preferences.getLogin()) {
        Navigator.pushReplacementNamed(context, '/ui/home');
      } else {
        Navigator.pushReplacementNamed(context, '/ui/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(Dimens.paddingApplication),
        child: Center(
          child: Image.asset(
            'images/main_logo_1.png',
            height: 120,
          ),
        ),
          ),
      );
  }
}
