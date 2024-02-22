import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icontrol/res/styles.dart';

import '../../config/application_messages.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';
import '../auth/login/login.dart';
import '../components/alert_dialog_generic.dart';
import '../components/custom_app_bar.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  final postRequest = PostRequest();
  User? _profileResponse;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> loadProfileRequest() async {
    try {
      final body = {
        "id": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LOAD_PROFILE, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = User.fromJson(parsedResponse);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> disableAccount() async {
    try {
      final body = {
        "id": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DISABLE_ACCOUNT, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      if (response.status == "01") {
        await Preferences.init();
        Preferences.clearUserData();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            ModalRoute.withName("/ui/login"));
      } else {}
      ApplicationMessages(context: context)
          .showMessage(response.msg + "\n\n" + Strings.enable_account);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            CustomAppBar(title: "Menu Principal", isVisibleBackButton: false),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                // Expanded(
                FutureBuilder<Map<String, dynamic>>(
                  future: loadProfileRequest(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final response = User.fromJson(snapshot.data!);

                      return Material(
                          elevation: Dimens.elevationApplication,
                          child: Container(
                            padding: EdgeInsets.all(Dimens.paddingApplication),
                            color: OwnerColors.lightGrey,
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: Dimens.marginApplication),
                                  child: ClipOval(
                                    child: SizedBox.fromSize(
                                      size: Size.fromRadius(32), // Image radius
                                      child: Image.network(
                                          ApplicationConstant.URL_AVATAR +
                                              response.avatar.toString(),
                                          fit: BoxFit.cover,
                                          /*fit: BoxFit.cover*/
                                          errorBuilder: (context, exception,
                                                  stackTrack) =>
                                              Image.asset(
                                                'images/main_logo_1.png',
                                              )),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        response.nome,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: Dimens.textSize6,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                          height: Dimens.minMarginApplication),
                                      Text(
                                        response.email,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: Dimens.textSize5,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.black38),
                                  onPressed: () => {
                                    Navigator.pushNamed(context, "/ui/profile")
                                  },
                                )
                              ],
                            ),
                          ));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                Visibility(
                    visible: Preferences.getUserData()!.tipo == 1,
                    child: Column(
                      children: [
                        InkWell(
                            child: Container(
                              padding:
                                  EdgeInsets.all(Dimens.maxPaddingApplication),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Histórico de pagamentos",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimens.minMarginApplication),
                                        Text(
                                          "Visualize pagamentos recentes",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, "/ui/payments");
                            }),
                        Styles().div_horizontal,
                        InkWell(
                            child: Container(
                              padding:
                                  EdgeInsets.all(Dimens.maxPaddingApplication),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Equipamentos",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimens.minMarginApplication),
                                        Text(
                                          "Gerencie Equipamentos",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "/ui/equipments");
                            }),
                        Styles().div_horizontal,
                        InkWell(
                            child: Container(
                              padding:
                                  EdgeInsets.all(Dimens.maxPaddingApplication),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Funcionários",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimens.minMarginApplication),
                                        Text(
                                          "Gerencie seus Funcionários",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, "/ui/employees");
                            }),
                        Styles().div_horizontal,
                      ],
                    )),

                InkWell(
                    child: Container(
                      padding: EdgeInsets.all(Dimens.maxPaddingApplication),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "FAQ",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Text(
                                  "Descubra Informações úteis",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize4,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {}),

                Styles().div_horizontal,

                InkWell(
                    child: Container(
                      padding: EdgeInsets.all(Dimens.maxPaddingApplication),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Desativar conta",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Text(
                                  "Desative completamente todas as funções da sua conta",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize4,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet<dynamic>(
                        isScrollControlled: true,
                        context: context,
                        shape: Styles().styleShapeBottomSheet,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return GenericAlertDialog(
                              title: Strings.attention,
                              content: Strings.disable_account,
                              btnBack: TextButton(
                                  child: Text(Strings.no,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.black54,
                                      )),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                              btnConfirm: TextButton(
                                  child: Text(Strings.yes),
                                  onPressed: () {
                                    disableAccount();
                                  }));
                        },
                      );
                    }),

                Styles().div_horizontal,

                InkWell(
                    child: Container(
                      padding: EdgeInsets.all(Dimens.maxPaddingApplication),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sair",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Text(
                                  "Deslogar desta conta",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize4,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet<dynamic>(
                        isScrollControlled: true,
                        context: context,
                        shape: Styles().styleShapeBottomSheet,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return GenericAlertDialog(
                              title: Strings.attention,
                              content: Strings.logout,
                              btnBack: TextButton(
                                  child: Text(
                                    Strings.no,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                              btnConfirm: TextButton(
                                  child: Text(Strings.yes),
                                  onPressed: () async {
                                    await Preferences.init();
                                    Preferences.clearUserData();

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Login()),
                                        ModalRoute.withName("/ui/login"));
                                  }));
                        },
                      );
                    }),

                Styles().div_horizontal,
              ],
            ),
          ),
        ));
  }
}
