import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icontrol/res/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/application_messages.dart';
import '../../../config/masks.dart';
import '../../../config/validator.dart';
import '../../../global/application_constant.dart';
import '../../../model/user.dart';
import '../../../res/dimens.dart';
import '../../../res/owner_colors.dart';
import '../../../web_service/links.dart';
import '../../../web_service/service_response.dart';
import '../../components/custom_app_bar.dart';
import '../../main/home.dart';

class RegisterOwnerData extends StatefulWidget {
  const RegisterOwnerData({Key? key}) : super(key: key);

  @override
  State<RegisterOwnerData> createState() => _RegisterOwnerDataState();
}

class _RegisterOwnerDataState extends State<RegisterOwnerData> {

  late bool _passwordVisible;
  late bool _passwordVisible2;

  bool hasPasswordCoPassword = false;
  bool hasUppercase = false;
  bool hasMinLength = false;
  bool visibileOne = false;
  bool visibileTwo = false;

  late bool _isLoading = false;


  late Validator validator;
  final postRequest = PostRequest();
  User? _registerResponse;

  @override
  void initState() {

    _passwordVisible = false;
    _passwordVisible2 = false;

    validator = Validator(context: context);
    super.initState();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController coPasswordController = TextEditingController();
  final TextEditingController cellphoneController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    coPasswordController.dispose();
    cellphoneController.dispose();
    ownerNameController.dispose();
    cpfController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(isVisibleBackButton: true,),
        body: Container(
            child: Container(
          child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(Dimens.minMarginApplication),
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
                          borderRadius: BorderRadius.circular(
                              Dimens.radiusApplication),
                        ),
                        margin: EdgeInsets.all(Dimens.minMarginApplication),
                        child: Container(
                            padding: EdgeInsets.all(Dimens.paddingApplication),
                            child: Column(children: [
                              TextField(
                                controller: ownerNameController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary,
                                        width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Nome responsável',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimens.radiusApplication),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(
                                      Dimens.textFieldPaddingApplication),
                                ),
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                controller: cpfController,
                                inputFormatters: [Masks().cpfMask()],
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary,
                                        width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'CPF',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimens.radiusApplication),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(
                                      Dimens.textFieldPaddingApplication),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                controller: cellphoneController,
                                inputFormatters: [Masks().cellphoneMask()],
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary,
                                        width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Celular',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimens.radiusApplication),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(
                                      Dimens.textFieldPaddingApplication),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary,
                                        width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'E-mail',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimens.radiusApplication),
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
                                onChanged: (value) {
                                  setState(() {
                                    hasPasswordCoPassword = false;
                                    visibileOne = true;
                                    hasMinLength = passwordController.text.length >= 8;
                                    hasUppercase = passwordController.text
                                        .contains(RegExp(r'[A-Z]'));

                                    hasPasswordCoPassword = coPasswordController.text ==
                                        passwordController.text;

                                    if (hasMinLength && hasUppercase) {
                                      visibileOne = false;
                                    }
                                  });
                                },
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
                                  contentPadding:
                                  EdgeInsets.all(Dimens.textFieldPaddingApplication),
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
                              SizedBox(height: 4),
                              Visibility(
                                visible: passwordController.text.isNotEmpty,
                                child: Row(
                                  children: [
                                    Icon(
                                      hasMinLength
                                          ? Icons.check_circle
                                          : Icons.check_circle,
                                      color: hasMinLength
                                          ? Colors.green
                                          : OwnerColors.lightGrey,
                                    ),
                                    Text(
                                      'Deve ter no mínimo 8 carácteres',
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: passwordController.text.isNotEmpty,
                                child: Row(
                                  children: [
                                    Icon(
                                      hasUppercase
                                          ? Icons.check_circle
                                          : Icons.check_circle,
                                      color: hasUppercase
                                          ? Colors.green
                                          : OwnerColors.lightGrey,
                                    ),
                                    Text(
                                      'Deve ter uma letra maiúscula',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    visibileTwo = true;
                                    hasPasswordCoPassword = coPasswordController.text ==
                                        passwordController.text;

                                    if (hasPasswordCoPassword) {
                                      visibileTwo = false;
                                    }
                                  });
                                },
                                controller: coPasswordController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible2
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: OwnerColors.colorPrimary,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible2 = !_passwordVisible2;
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
                                  hintText: 'Confirmar Senha',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(Dimens.radiusApplication),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                  EdgeInsets.all(Dimens.textFieldPaddingApplication),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !_passwordVisible2,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Visibility(
                                visible: coPasswordController.text.isNotEmpty,
                                child: Row(
                                  children: [
                                    Icon(
                                      hasPasswordCoPassword
                                          ? Icons.check_circle
                                          : Icons.check_circle,
                                      color: hasPasswordCoPassword
                                          ? Colors.green
                                          : OwnerColors.lightGrey,
                                    ),
                                    Text(
                                      'As senhas fornecidas são idênticas',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Dimens.textSize5,
                                    fontFamily: 'Inter',
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                        'Ao clicar no botão Avançar, você aceita os'),
                                    TextSpan(
                                        text: ' Termos de uso',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: Dimens.textSize5,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                                context, "/ui/pdf_viewer");
                                          }),
                                    TextSpan(text: ' do aplicativo.'),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: Dimens.marginApplication),
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: Styles().styleDefaultButton,
                                    onPressed: () {
                                     /* if (!validator.validateGenericTextField(
                                          ownerNameController.text,
                                          "Nome resposável")) return;
                                      if (!validator.validateCPF(
                                          cpfController.text)) return;
                                      if (!validator.validateCellphone(
                                          cellphoneController.text)) return;
                                      if (!validator.validateEmail(
                                          emailController.text)) return;
                                      if (!validator.validatePassword(
                                          passwordController.text)) return;
                                      if (!validator.validateCoPassword(
                                          passwordController.text,
                                          coPasswordController.text)) return;*/


                                      Navigator.pushNamed(context, "/ui/register_company_data", arguments: {
                                        "owner_name": ownerNameController.text.toString(),
                                        "cellphone": cellphoneController.text.toString(),
                                        "email": emailController.text.toString(),
                                        "password": passwordController.text.toString(),
                                        "cpf": cpfController.text.toString(),
                                      });

                                    },
                                    child: Text(
                                      "Avançar",
                                      style: Styles().styleDefaultTextButton
                                    )),
                              ),
                            ]))),
                  ],
                ),
              ),
            )),
          ]),
        )));
  }
}
