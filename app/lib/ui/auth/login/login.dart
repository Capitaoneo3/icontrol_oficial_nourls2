import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icontrol/config/validator.dart';
import 'package:icontrol/global/application_constant.dart';
import 'package:icontrol/model/user.dart';
import 'package:icontrol/web_service/service_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/application_messages.dart';
import '../../../config/preferences.dart';
import '../../../res/dimens.dart';
import '../../../res/owner_colors.dart';
import '../../../res/styles.dart';
import '../../../web_service/links.dart';
import '../../components/custom_app_bar.dart';
import '../../main/home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late bool _passwordVisible;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  late Validator validator;
  final postRequest = PostRequest();
  User? _loginResponse;

  // Future<void> loginRequest(String email, String password) async {
  //   try {
  //     final body = {
  //       "email": email,
  //       "password": password,
  //       "token": ApplicationConstant.TOKEN
  //     };
  //
  //     print('HTTP_BODY: $body');
  //
  //     final json = await postRequest.sendPostRequest(Links.LOGIN, body);
  //     // final parsedResponse = jsonDecode(json); // pegar um objeto so
  //
  //     List<Map<String, dynamic>> _map = [];
  //     _map = List<Map<String, dynamic>>.from(jsonDecode(json));
  //
  //     print('HTTP_RESPONSE: $_map');
  //
  //     final response = User.fromJson(_map[0]);
  //
  //     if (response.status == "01") {
  //       // setState(() async {
  //         _loginResponse = response;
  //
  //         await Preferences.setUserData(_loginResponse);
  //         await Preferences.setLogin(true);
  //
  //         if (response.tipo == 1) {
  //
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(builder: (context) => Home()),
  //               ModalRoute.withName("/ui/home"));
  //         } else {
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(builder: (context) => Home()),
  //               ModalRoute.withName("/ui/home"));
  //         }
  //
  //       // });
  //     } else {
  //       ApplicationMessages(context: context).showMessage(response.msg);
  //     }
  //   } catch (e) {
  //     throw Exception('HTTP_ERROR: $e');
  //   }
  // }

  Future<void> fakeLogin(String email, String password) async {
    try {
      Navigator.pushNamed(context, "/ui/validation_code", arguments: {
        "email": email,
        "password": password,
      });
      return;

      final body = {
        "email": email,
        "password": password,
        "latitude": "",
        "longitude": "",
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.VERIFY_TWO_FACTORS, body);
      // final parsedResponse = jsonDecode(json); // pegar um objeto so

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      if (response.status == "01") {

        Navigator.pushNamed(context, "/ui/validation_code", arguments: {
          "email": email,
          "password": password,
        });
      } else {
        ApplicationMessages(context: context).showMessage(response.msg);
      }
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> codeLogin(String email, String password, String code) async {
    try {
      final body = {
        "email": email,
        "password": password,
        "codigo": code,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LOGIN_TWO_FACTORS, body);
      // final parsedResponse = jsonDecode(json); // pegar um objeto so

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      if (response.status == "01") {

      } else {
        ApplicationMessages(context: context).showMessage(response.msg);
      }
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validator = Validator(context: context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(isVisibleBackButton: true),
      body: Container(
        margin: EdgeInsets.all(Dimens.minMarginApplication),
        child: SafeArea(
          child: Container(
              child: CustomScrollView(slivers: [
                SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimens.paddingApplication),
                    child: Center(
                      child: Image.asset(
                        'images/main_logo_1.png',
                        height: 90,
                      ),
                    ),
                  ),
                  Card(
                      elevation: Dimens.minElevationApplication,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimens.radiusApplication),
                      ),
                      margin: EdgeInsets.all(Dimens.minMarginApplication),
                      child: Container(
                        padding: EdgeInsets.all(Dimens.paddingApplication),
                        child: Column(children: [
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: OwnerColors.colorPrimary, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              hintText: 'E-mail',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(Dimens.radiusApplication),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.all(
                                  Dimens.textFieldPaddingApplication),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: Dimens.textSize5,
                            ),
                          ),
                          SizedBox(height: Dimens.marginApplication),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: OwnerColors.colorPrimary,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  }),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: OwnerColors.colorPrimary, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              hintText: 'Senha',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(Dimens.radiusApplication),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.all(
                                  Dimens.textFieldPaddingApplication),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !_passwordVisible,
                            enableSuggestions: false,
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: Dimens.textSize5,
                            ),
                          ),
                          SizedBox(height: Dimens.minMarginApplication),
                          Container(width: double.infinity, child:
                          RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: Dimens.textSize5,
                                fontFamily: 'Inter',
                              ),
                              children: <TextSpan>[
                                TextSpan(text: 'Esqueceu sua senha? '),
                                TextSpan(
                                    text: 'Entre aqui',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: Dimens.textSize5,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {

                                        Navigator.pushNamed(context, "/ui/recover_password");
                                      }),

                              ],
                            ),
                          )),
                          Container(
                            margin: EdgeInsets.only(top: Dimens.marginApplication),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: Styles().styleDefaultButton,
                              onPressed: () async {

                               /* if (!validator
                                    .validateEmail(emailController.text)) return;
*/
                                setState(() {
                                  _isLoading = true;
                                });
                                // if (!validator.validatePassword(passwordController.text)) return;
                                await Preferences.init();
                                await fakeLogin(
                                    emailController.text, passwordController.text);

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              child: (_isLoading)
                                  ? const SizedBox(
                                  width: Dimens.buttonIndicatorWidth,
                                  height: Dimens.buttonIndicatorHeight,
                                  child: CircularProgressIndicator(
                                    color: OwnerColors.colorAccent,
                                    strokeWidth: Dimens.buttonIndicatorStrokes,
                                  ))
                                  : Text("Entrar",
                                  style: Styles().styleDefaultTextButton),
                            ),
                          ),
                        ]),
                      )),
                  Spacer(),
                  SizedBox(height: Dimens.marginApplication),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: Dimens.textSize5,
                        fontFamily: 'Inter',
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Ainda não possui uma conta? '),
                        TextSpan(
                            text: 'Entre aqui',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: Dimens.textSize5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {

                                Navigator.pushNamed(context, "/ui/register_owner_data");
                              }),

                      ],
                    ),
                  )
                ],
              ),
            )])),
        ),
      ),
    );
  }
}
