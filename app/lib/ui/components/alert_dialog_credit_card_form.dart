import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

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

class CreditCardAlertDialog extends StatefulWidget {

  final String? idPlan;
  final String? paymentType;
  final String? value;

  CreditCardAlertDialog({
    Key? key,
    this.idPlan,
    this.paymentType,
    this.value,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<CreditCardAlertDialog> createState() => _CreditCardAlertDialog();
}

class _CreditCardAlertDialog extends State<CreditCardAlertDialog> {
  bool _isLoading = false;


  late Validator validator;
  final postRequest = PostRequest();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController securityCodeController = TextEditingController();

  @override
  void initState() {
    validator = Validator(context: context);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    yearController.dispose();
    monthController.dispose();
    cardNumberController.dispose();
    securityCodeController.dispose();
    super.dispose();
  }

  Future<void> createTokenCreditCard(
      String idPlan,
      String cardNumber,
      String expirationMonth,
      String expirationYear,
      String securityCode,
      String name,
      String document) async {
    try {
      final body = {
        "card_number": cardNumber,
        "expiration_month": expirationMonth,
        "expiration_year": expirationYear,
        "security_code": securityCode,
        "nome": name,
        "cpf": document,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
      await postRequest.sendPostRequest(Links.CREATE_TOKEN_CARD, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Payment.fromJson(parsedResponse);

      if (response.status == 400) {
        ApplicationMessages(context: context)
            .showMessage("Não foi possível autenticar este cartão!");
      } else {
        await payWithCreditCard(idPlan, response.id);
      }

      // setState(() {});
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> payWithCreditCard(String idPlan, String idCreditCard) async {
    try {
      final body = {
        "id_plano": idPlan,
        "id_usuario": Preferences.getUserData()!.id,
        "tipo_pagamento": ApplicationConstant.CREDIT_CARD,
        "payment_id": "",
        "card": idCreditCard,
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
        Navigator.pushNamedAndRemoveUntil(
            context, "/ui/success", (route) => false,
            arguments: {
              "payment_type": widget.paymentType,
              "total_value": widget.value,
            });
      } else {}

      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                CreditCardWidget(
                  cardHolderName: nameController.text,
                  cardNumber: cardNumberController.text,
                  expiryDate: monthController.text + " " + yearController.text,
                  cvvCode: securityCodeController.text,
                  showBackView: false,
                  isHolderNameVisible: true,
                  obscureCardCvv: false,
                  obscureInitialCardNumber: false,
                  obscureCardNumber: false,
                  onCreditCardWidgetChange:
                      (CreditCardBrand) {}, //true when you want to show cvv(back) view
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Preencha os dados do cartão:",
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
                  controller: nameController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Nome completo',
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
                TextField(
                  controller: cpfController,
                  inputFormatters: [Masks().cpfMask()],
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'CPF',
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
                Styles().div_horizontal,
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  maxLength: 19,
                  controller: cardNumberController,
                  decoration: InputDecoration(
                    counter: SizedBox(
                      width: 0,
                      height: 0,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Número do cartão',
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
                        maxLength: 2,
                        controller: monthController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: OwnerColors.colorPrimary, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          hintText: 'Mês de expiração',
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
                    SizedBox(width: Dimens.marginApplication),
                    Expanded(
                      child: TextField(
                        maxLength: 4,
                        controller: yearController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: OwnerColors.colorPrimary, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          hintText: 'Ano de expiração',
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
                  maxLength: 4,
                  controller: securityCodeController,
                  decoration: InputDecoration(
                      counter: SizedBox(
                        width: 0,
                        height: 0,
                      ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Código de segurança',
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
                Container(
                  margin: EdgeInsets.only(
                      top:
                      Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                    Styles().styleDefaultButton,
                    onPressed: _isLoading
                        ? null
                        : () async {
                 /*     if (!validator
                          .validateGenericTextField(
                          nameController
                              .text,
                          "Nome")) return;
                      if (!validator
                          .validateCPF(
                          cpfController
                              .text))
                        return;*/

                      setState(() {
                        _isLoading =
                        true;
                      });

                      var _formattedCardNumber =
                      cardNumberController
                          .text
                          .replaceAll(
                          new RegExp(
                              r'[^0-9]'),
                          '');

                      await createTokenCreditCard(
                          widget.idPlan.toString(),
                          _formattedCardNumber
                              .toString(),
                          monthController.text
                              .toString(),
                          yearController.text
                              .toString(),
                          securityCodeController
                              .text
                              .toString(),
                          nameController.text
                              .toString(),
                          cpfController.text
                              .toString());

                      setState(() {
                        _isLoading =
                        false;
                      });

                      // Navigator.of(context)
                      //     .pop();
                    },
                    child: (_isLoading)
                        ? const SizedBox(
                        width: Dimens
                            .buttonIndicatorWidth,
                        height: Dimens
                            .buttonIndicatorHeight,
                        child:
                        CircularProgressIndicator(
                          color: OwnerColors
                              .colorAccent,
                          strokeWidth: Dimens
                              .buttonIndicatorStrokes,
                        ))
                        : Text("Assinar agora",
                        style: Styles()
                            .styleDefaultTextButton),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
