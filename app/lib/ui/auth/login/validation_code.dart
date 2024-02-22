import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icontrol/res/dimens.dart';
import 'package:icontrol/res/owner_colors.dart';
import 'package:icontrol/res/strings.dart';

import '../../../config/application_messages.dart';
import '../../../config/preferences.dart';
import '../../../global/application_constant.dart';
import '../../../model/user.dart';
import '../../../res/styles.dart';
import '../../../web_service/links.dart';
import '../../../web_service/service_response.dart';
import '../../components/custom_app_bar.dart';
import '../../main/home.dart';

class ValidationCode extends StatefulWidget {


  ValidationCode(
      {super.key,});

  @override
  State<ValidationCode> createState() => _ValidationCodeState();
}

class _ValidationCodeState extends State<ValidationCode> {
  List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  String code = '';

  String _email = '';
  String _password = '';

  late bool _isLoading = false;

  User? _loginResponse;

  final postRequest = PostRequest();

  Future<void> resendCode(String email, String password) async {
    try {
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

        ApplicationMessages(context: context).showMessage(response.msg);
        // ApplicationMessages(context: context).showMessage(Strings.code);
      } else {
        ApplicationMessages(context: context).showMessage(response.msg);
      }
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> codeLogin(String email, String password, String code) async {
    try {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          ModalRoute.withName("/ui/home"));
      return;
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
        _loginResponse = response;

        await Preferences.init();
        await Preferences.setUserData(_loginResponse);
        await Preferences.setLogin(true);

        if (response.tipo == 1) {

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              ModalRoute.withName("/ui/home"));
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              ModalRoute.withName("/ui/home"));
        }
      } else {
        ApplicationMessages(context: context).showMessage(response.msg);
      }
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  String getCodeFromControllers(List<TextEditingController> controllers) {
    String code = '';
    for (var controller in controllers) {
      code += controller.text;
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {

    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _email = data['email'];
    _password = data['password'];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Autenticação 2 etapas",
        isVisibleBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimens.marginApplication,),
                  Text(
                    'Digite o código enviado para o seu email: ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    '${_email}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),

                  SizedBox(height: Dimens.marginApplication,),
                  SizedBox(height: Dimens.marginApplication,),
                  InkWell(
                    onTap: () {

                      resendCode(_email, _password);

                    },
                    child: Text(
                      'Reenviar codigo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: OwnerColors.colorPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: OwnerColors.colorPrimary,
                        decorationThickness: 1.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SMSCodeInputField(
                    code: code,
                    controllers: _controllers,
                  ),
                ],
              ),
            ),
           Container(
             margin: EdgeInsets.all(Dimens.minMarginApplication),
                width: double.infinity,
                child: ElevatedButton(
                  style: Styles().styleDefaultButton,
                  onPressed: () async {

                    String codefull = getCodeFromControllers(_controllers);

                    setState(() {
                      _isLoading = true;
                    });
                    await codeLogin(_email, _password, codefull);

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

          ],
        ),
      ),
    );
  }

}

class SMSCodeInputField extends StatefulWidget {
  String code;
  List<TextEditingController> controllers;

  SMSCodeInputField({
    super.key,
    required this.code,
    required this.controllers,
  });

  @override
  _SMSCodeInputFieldState createState() => _SMSCodeInputFieldState();
}

class _SMSCodeInputFieldState extends State<SMSCodeInputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 4; i++)
              Container(
                width: 50,
                height: 50,
                padding: EdgeInsets.only(bottom: 15, left: 2),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: OwnerColors.colorPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                      8.0), // Ajuste o valor de acordo com o arredondamento desejado
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: widget.controllers[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    // Centraliza o texto
                    style: TextStyle(
                        fontSize: 22, color: OwnerColors.colorPrimary),
                    decoration: InputDecoration(
                      counterText: '', // Remove a contagem de caracteres
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          // Remove a borda azul quando focado
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .transparent, // Remove a borda azul quando não focado
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      // Quando um dígito é digitado, você pode realizar alguma ação aqui.
                      // Por exemplo, mover o foco para o próximo campo.
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      setState(() {
                        widget.code = value;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     for (int i = 0; i < 4; i++)
        //       Container(width: 50, height: 2, margin: EdgeInsets.symmetric(horizontal: 10), color: MyColors.colorPrimary,),
        //   ],
        // )
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in widget.controllers) {
      controller.dispose();
    };
    super.dispose();
  }
}
