import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icontrol/res/dimens.dart';
import 'package:icontrol/res/owner_colors.dart';
import 'package:icontrol/res/strings.dart';
import 'package:icontrol/res/styles.dart';
import 'package:icontrol/ui/auth/login/login.dart';
import 'package:icontrol/ui/components/dot_indicator.dart';

// VAI NA LINHA 68
class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController _pageController;
  int _pageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(
                height: 36),
            Container(
                padding: EdgeInsets.all(Dimens.maxPaddingApplication),
                child: Image.asset(
                  'images/main_logo_1.png',
                  height: 90,
                )),
            Expanded(
                child: PageView.builder(
                    itemCount: demo_data.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) => OnboardingContent(
                          image: demo_data[index].image,
                          title: demo_data[index].title,
                          subtitle: demo_data[index].subtitle,
                        ))),
            SizedBox(
              child: Container(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: Dimens.paddingApplication),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(
                              demo_data.length,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: DotIndicator(
                                      isActive: index == _pageIndex,
                                      color: OwnerColors.colorPrimary,
                                    ),
                                  )),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(Dimens.minMarginApplication),
                        child: ElevatedButton(
                            style: Styles().styleDefaultButton,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                  ModalRoute.withName("/ui/login"));
                            },
                            child: Text(
                              "Pular",
                              style: Styles().styleDefaultTextButton,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Onboard {
  final String image, title, subtitle;

  const Onboard(
      {required this.title, required this.image, required this.subtitle});
}

final List<Onboard> demo_data = [
  Onboard(
    image: '',
    title: "",
    subtitle: "A Água da Serra é uma marca historicamente jovem.",
  ),
  Onboard(
    image: '',
    title: "",
    subtitle: "Agora com mais sabores além do original",
  ),
  Onboard(
    image: '',
    title: "",
    subtitle: "Sabores para todos os gostos",
  ),
  Onboard(
    image: '',
    title: "",
    subtitle: "Sabores para todos os gostos",
  )
];

class OnboardingContent extends StatelessWidget {
  final String image, title, subtitle;

  const OnboardingContent(
      {Key? key,
      required this.title,
      required this.image,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Card(
            elevation: Dimens.minElevationApplication,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusApplication),
            ),
            margin: EdgeInsets.all(Dimens.minMarginApplication),
            child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(Dimens.paddingApplication),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Strings.littleLoremIpsum,
                        style: Styles().styleTitleText,
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          Strings.longLoremIpsum,
                          style: Styles().styleDescriptionText,
                        ),
                      ))
                    ]))));
  }
}
