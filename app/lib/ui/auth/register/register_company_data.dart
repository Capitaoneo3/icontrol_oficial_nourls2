import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/application_messages.dart';
import '../../../config/masks.dart';
import '../../../config/validator.dart';
import '../../../global/application_constant.dart';
import '../../../model/user.dart';
import '../../../res/dimens.dart';
import '../../../res/owner_colors.dart';
import '../../../res/styles.dart';
import '../../../web_service/links.dart';
import '../../../web_service/service_response.dart';
import '../../components/custom_app_bar.dart';
import '../../main/home.dart';

class RegisterCompanyData extends StatefulWidget {
  const RegisterCompanyData({Key? key}) : super(key: key);

  @override
  State<RegisterCompanyData> createState() => _RegisterCompanyDataState();
}

class _RegisterCompanyDataState extends State<RegisterCompanyData> {

  late Validator validator;



  @override
  void initState() {
    validator = Validator(context: context);
    super.initState();
  }

  @override
  void dispose() {
    socialReasonController.dispose();
    cnpjController.dispose();
    fantasyNameController.dispose();
    super.dispose();
  }

  final TextEditingController socialReasonController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController fantasyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

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
                                controller: socialReasonController,
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
                                  hintText: 'Razão Social',
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
                                controller: fantasyNameController,
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
                                  hintText: 'Nome Fantasia',
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
                                controller: cnpjController,
                                inputFormatters: [Masks().cnpjMask()],
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
                                  hintText: 'CNPJ',
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
                              Container(
                                margin: EdgeInsets.only(
                                    top: Dimens.marginApplication),
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: Styles().styleDefaultButton,
                                    onPressed: () {
                                   /*   if (!validator.validateGenericTextField(
                                          socialReasonController.text,
                                          "Razão social")) return;
                                      if (!validator.validateGenericTextField(
                                          fantasyNameController.text,
                                          "Nome fantasia")) return;
                                      if (!validator.validateCNPJ(
                                          cnpjController.text)) return;
*/

                                      Navigator.pushNamed(context, "/ui/register_address_form",
                                          arguments: {
                                        "owner_name": data['owner_name'],
                                        "cellphone": data['cellphone'],
                                        "email": data['email'],
                                        "password": data['password'],
                                        "cpf": data['cpf'],
                                        "social_reason": socialReasonController.text.toString(),
                                        "fantasy_name": fantasyNameController.text.toString(),
                                        "cnpj": cnpjController.text.toString(),
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
