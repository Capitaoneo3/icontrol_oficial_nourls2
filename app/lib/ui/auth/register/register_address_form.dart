import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/application_messages.dart';
import '../../../config/masks.dart';
import '../../../config/preferences.dart';
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

class RegisterAddressForm extends StatefulWidget {
  const RegisterAddressForm({Key? key}) : super(key: key);

  @override
  State<RegisterAddressForm> createState() => _RegisterAddressFormState();
}

class _RegisterAddressFormState extends State<RegisterAddressForm> {

  bool _isLoading = false;
  late Validator validator;
  final postRequest = PostRequest();

  @override
  void initState() {
    validator = Validator(context: context);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    cepController.dispose();
    cityController.dispose();
    stateController.dispose();
    nbhController.dispose();
    addressController.dispose();
    numberController.dispose();
    complementController.dispose();
    super.dispose();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController nbhController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController complementController = TextEditingController();


  Future<void> getCepInfo(String cep) async {
    try {
      final json = await postRequest.getCepRequest("$cep/json/");

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = User.fromJson(parsedResponse);

      setState(() {
        cityController.text = response.localidade;
        stateController.text = response.uf;
        nbhController.text = response.bairro;
        addressController.text = response.logradouro;
      });
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }


  Future<void> registerRequest(
      String email,
      String password,
      String ownerName,
      String cpf,
      String cellphone,
      String fantasyName,
      String socialReason,
      String cnpj,
      String cep,
      String state,
      String city,
      String address,
      String nbh,
      String number,
      String complement) async {

    try {
      fakeLogin(email, password);
      return;
      final body = {
        "razao_social": socialReason,
        "nome_fantasia": fantasyName,
        "nome_responsavel": ownerName,
        "cpf_responsavel": cpf,
        "cnpj": cnpj,
        "email": email,
        "celular": cellphone,
        "password": password,
        "cep": cep,
        "estado": state,
        "cidade": city,
        "bairro": nbh,
        "endereco": address,
        "numero": number,
        "complemento": complement,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.REGISTER_W_ADDRESS, body);
      // final parsedResponse = jsonDecode(json); // pegar um objeto so

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      if (response.status == "01") {
        // setState(() {
        //   await Preferences.setUserData(response);
        //   await Preferences.setLogin(true);
        //
        //   Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(builder: (context) => Home()),
        //       ModalRoute.withName("/ui/home"));
        // });
        fakeLogin(email, password);
      } else {
        ApplicationMessages(context: context).showMessage(response.msg);
      }
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> fakeLogin(String email, String password) async {
    try {
      Navigator.pushNamed(context, "/ui/validation_code", arguments: {
        "email": email,
        "password": password,
      });

      /*final body = {
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
      }*/
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

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
                                onChanged: (value) {
                                  if (value.length > 8) {
                                    getCepInfo(value);
                                  }
                                },
                                controller: cepController,
                                inputFormatters: [Masks().cepMask()],
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'CEP',
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
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      readOnly: true,
                                      controller: cityController,
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: OwnerColors.colorPrimary, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                        hintText: 'Cidade',
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
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: Dimens.textSize5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Dimens.marginApplication),
                                  Expanded(
                                    child: TextField(
                                      readOnly: true,
                                      controller: stateController,
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: OwnerColors.colorPrimary, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                        hintText: 'Estado',
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
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: Dimens.textSize5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Endereço',
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
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: Dimens.textSize5,
                                ),
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: nbhController,
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: OwnerColors.colorPrimary, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                        hintText: 'Bairro',
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
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: Dimens.textSize5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Dimens.marginApplication),
                                  Expanded(
                                    child: TextField(
                                      controller: numberController,
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: OwnerColors.colorPrimary, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                        hintText: 'Número',
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
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: Dimens.textSize5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimens.marginApplication),
                              TextField(
                                controller: complementController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: OwnerColors.colorPrimary, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Complemento(opcional)',
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
                                keyboardType: TextInputType.text,
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
                                    onPressed: _isLoading
                                        ? null
                                        : () async {

                                    /*  if (!validator.validateCEP(cepController.text)) return;
                                      if (!validator.validateGenericTextField(
                                          cityController.text, "Cidade")) return;
                                      if (!validator.validateGenericTextField(
                                          stateController.text, "Estado")) return;
                                      if (!validator.validateGenericTextField(
                                          addressController.text, "Endereço")) return;
                                      if (!validator.validateGenericTextField(
                                          nbhController.text, "Bairro")) return;
                                      if (!validator.validateGenericTextField(
                                          numberController.text, "Número")) return;*/

                                      setState(() {
                                        _isLoading = true;
                                      });

                                      await registerRequest(
                                          data['email'],
                                          data['password'],
                                          data['owner_name'],
                                          data['cpf'],
                                          data['cellphone'],
                                          data['fantasy_name'],
                                          data['social_reason'],
                                          data['cnpj'],
                                          cepController.text.toString(),
                                          stateController.text.toString(),
                                          cityController.text.toString(),
                                          addressController.text.toString(),
                                          nbhController.text.toString(),
                                          numberController.text.toString(),
                                          complementController.text.toString());

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
                                        : Text("Finalizar cadastro",
                                        style: Styles().styleDefaultTextButton),
                                    ),
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
