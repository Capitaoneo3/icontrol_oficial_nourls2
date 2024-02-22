import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/payment.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class AddressCheckoutFormAlertDialog extends StatefulWidget {
  final String? idPlan;
  final String? paymentType;
  final String? value;

  final String? cep;
  final String? city;
  final String? state;
  final String? nbh;
  final String? address;
  final String? number;
  final String? complement;

  AddressCheckoutFormAlertDialog({
    Key? key,
    this.idPlan,
    this.paymentType,
    this.value,
    this.cep,
    this.city,
    this.state,
    this.nbh,
    this.address,
    this.number,
    this.complement,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<AddressCheckoutFormAlertDialog> createState() =>
      _AddressCheckoutFormAlertDialog();
}

class _AddressCheckoutFormAlertDialog
    extends State<AddressCheckoutFormAlertDialog> {
  late Validator validator;
  final postRequest = PostRequest();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController nbhController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController complementController = TextEditingController();

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

  Future<void> payWithTicket(String idPlan, String cep, String state,
      String city, String address, String nbh, String number) async {
    try {
      final body = {
        "id_plano": idPlan,
        "id_usuario": Preferences.getUserData()!.id,
        "tipo_pagamento": ApplicationConstant.TICKET,
        "cep": cep,
        "estado": state,
        "cidade": city,
        "endereco": address,
        "bairro": nbh,
        "numero": number,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.ADD_PAYMENT, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Payment.fromJson(_map[0]);

      Navigator.of(context).pop;
      if (response.status == "01") {
        setState(() {
          Navigator.pushNamedAndRemoveUntil(
              context, "/ui/success", (route) => false,
              arguments: {
                "payment_type": widget.paymentType,
                "barCode": response.cod_barras,
                "total_value": widget.value,
              });
        });
      } else {}

      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    validator = Validator(context: context);

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
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Adicione dados de endereço",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
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
                  margin: EdgeInsets.only(top: Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Styles().styleDefaultButton,
                    onPressed: () async {
                     /* if (!validator.validateCEP(cepController.text)) return;
                      if (!validator.validateGenericTextField(
                          cityController.text, "Cidade")) return;
                      if (!validator.validateGenericTextField(
                          stateController.text, "Estado")) return;
                      if (!validator.validateGenericTextField(
                          addressController.text, "Endereço")) return;
                      if (!validator.validateGenericTextField(
                          nbhController.text, "Bairro")) return;
                      if (!validator.validateGenericTextField(
                          numberController.text, "Número")) return;
*/
                      setState(() {
                        _isLoading = true;
                      });

                      await payWithTicket(
                          widget.idPlan.toString(),
                          cepController.text.toString(),
                          stateController.text.toString(),
                          cityController.text.toString(),
                          addressController.text.toString(),
                          nbhController.text.toString(),
                          numberController.text.toString()
                          );

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
                        : Text("Finalizar",
                            style: Styles().styleDefaultTextButton),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
