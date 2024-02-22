import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icontrol/ui/components/alert_dialog_address_checkout_form.dart';

import '../../../../config/application_messages.dart';
import '../../../../config/preferences.dart';
import '../../../../global/application_constant.dart';
import '../../../../model/user.dart';
import '../../../../res/dimens.dart';
import '../../../../res/owner_colors.dart';
import '../../../../res/strings.dart';
import '../../../../web_service/links.dart';
import '../../../../web_service/service_response.dart';
import '../../../config/validator.dart';
import '../../../model/payment.dart';
import '../../../res/styles.dart';
import '../../components/alert_dialog_credit_card_form.dart';
import '../../components/custom_app_bar.dart';

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _Checkout();
}

class _Checkout extends State<Checkout> {
  bool _isLoading = false;
  bool _isLoadingDialog = false;

  late int _idPlan;
  late String _typePayment;
  late int _days;
  late String _typePlan;
  late String _value;
  late String _desc;

  late Validator validator;
  final postRequest = PostRequest();

  var _typePaymentName;


  Future<void> payWithPIX(String idPlan) async {
    try {
      final body = {
        "id_plano": idPlan,
        "id_usuario": Preferences.getUserData()!.id,
        "tipo_pagamento": ApplicationConstant.PIX,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.ADD_PAYMENT, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Payment.fromJson(_map[0]);

      if (response.status == "01") {
        Navigator.pushNamedAndRemoveUntil(
            context, "/ui/success", (route) => false,
            arguments: {
              "payment_type": _typePaymentName,
              "base64": response.qrcode_64,
              "qrCodeClipboard": response.qrcode,
              "total_value": _value,
            });
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _typePayment = data['type_payment'];
    _idPlan = data['id_plan'];
    _days = data['days'];
    _value = data['value'];
    _typePlan = data['name_plan'];
    _desc = data['desc'];

    switch (_typePayment) {
      case "1":
        _typePaymentName = "Cartão de crédito";
        break;
      case "2":
        _typePaymentName = "Boleto bancário";
        break;
      case "3":
        _typePaymentName = "PIX";
        break;
      case "4":
        _typePaymentName = "Boleto à prazo";
        break;
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: "",
          isVisibleBackButton: true,
        ),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: /*FutureBuilder<List<Map<String, dynamic>>>(
              future: loadProduct(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {

                  final response = Product.fromJson(snapshot.data![0]);

                  return */
                Stack(children: [
              SingleChildScrollView(
                  child: Container(
                padding: EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.all(Dimens.marginApplication),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Resumo da assinatura",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 40),
                            // SizedBox(height: Dimens.minMarginApplication),
                            // Text(
                            //   "Tipo de pagamento: $_typePaymentName",
                            //   style: TextStyle(
                            //     fontFamily: 'Inter',
                            //     fontSize: Dimens.textSize5,
                            //     color: Colors.black,
                            //   ),
                            // ),

                            Card(
                                elevation: 0.5,
                                color: OwnerColors.colorPrimary,
                                margin:
                                    EdgeInsets.all(Dimens.minMarginApplication),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        padding: EdgeInsets.only(
                                            left: Dimens.paddingApplication,
                                            bottom: Dimens.paddingApplication,
                                            top: Dimens.paddingApplication),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                height: Dimens
                                                    .minMarginApplication),
                                            Text(
                                              _typePlan.toUpperCase(),
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: Dimens.textSize7,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _days.toString() + " DIAS",
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: Dimens.textSize5,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )),
                                      Expanded(
                                          child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(40))),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        top: 40,
                                                        bottom: 40,
                                                        left: Dimens
                                                            .marginApplication),
                                                    child: Text(
                                                      "R\$",
                                                      style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize:
                                                              Dimens.textSize6,
                                                          color: OwnerColors
                                                              .colorPrimary,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        top: 40,
                                                        bottom: 40,
                                                        right: 30),
                                                    child: Text(
                                                        _value.replaceAll(
                                                            "R\$ ", ""),
                                                        style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: Dimens
                                                                .textSize9,
                                                            color: OwnerColors
                                                                .colorPrimary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ]),
                                            ]),
                                      )),
                                    ],
                                  ),
                                )),
                            SizedBox(height: 20),
                            Text(
                              textAlign: TextAlign.center,
                              _desc,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize6,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: 40),
                            Text(
                              "Validade de " + _days.toString() + " dias",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize6,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),

                            Text(
                              textAlign: TextAlign.center,
                              "Efetue a renovação manualmente ou cancele sua assinatura a qualquer momento",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              )),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Container(
                    //   margin: EdgeInsets.all(Dimens.minMarginApplication),
                    //   width: double.infinity,
                    //   child: Card(
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(
                    //             Dimens.minRadiusApplication),
                    //       ),
                    //       child: Container(
                    //           padding:
                    //               EdgeInsets.all(Dimens.paddingApplication),
                    //           child: Column(children: [
                    //             Row(
                    //               children: [
                    //                 Expanded(
                    //                   child: Text(
                    //                     "Valor total",
                    //                     style: TextStyle(
                    //                       fontFamily: 'Inter',
                    //                       fontSize: Dimens.textSize6,
                    //                       color: Colors.black,
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   "",
                    //                   style: TextStyle(
                    //                       fontFamily: 'Inter',
                    //                       fontSize: Dimens.textSize6,
                    //                       color: Colors.black,
                    //                       fontWeight: FontWeight.bold),
                    //                 ),
                    //               ],
                    //             ),
                    //             SizedBox(height: Dimens.marginApplication),
                    Container(
                        margin: EdgeInsets.all(Dimens.marginApplication),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: Styles().styleDefaultButton,
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  if (_typePayment ==
                                      ApplicationConstant.CREDIT_CARD
                                          .toString()) {
                                    /*final result = */ await showModalBottomSheet<
                                            dynamic>(
                                        isScrollControlled: true,
                                        context: context,
                                        shape: Styles().styleShapeBottomSheet,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        builder: (BuildContext context) {
                                          return CreditCardAlertDialog(idPlan: _idPlan.toString(),
                                              paymentType: _typePaymentName,
                                              value: _value,
                                          );
                                        });
                                  } else if (_typePayment ==
                                      ApplicationConstant.PIX.toString()) {
                                    await payWithPIX(_idPlan.toString());
                                  } else {
                                    final result =
                                        await showModalBottomSheet<dynamic>(
                                            isScrollControlled: true,
                                            context: context,
                                            shape:
                                                Styles().styleShapeBottomSheet,
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            builder: (BuildContext context) {
                                              return AddressCheckoutFormAlertDialog(
                                                idPlan: _idPlan.toString(),
                                                paymentType: _typePaymentName,
                                                value: _value,
                                              );
                                            });
                                    if (result == true) {
                                      setState(() {});
                                    }

                                  }

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
                              : Text(
                                  _typePaymentName == "Cartão de crédito"
                                      ? "Inserir dados do cartão"
                                      : "Assinar agora",
                                  style: Styles().styleDefaultTextButton),
                        )),
                    //           ]))),
                    // )
                  ])
            ])));
    /*     } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return Center( child: CircularProgressIndicator());
              },
            )));*/
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;

      _isLoading = false;
    });
  }
}
