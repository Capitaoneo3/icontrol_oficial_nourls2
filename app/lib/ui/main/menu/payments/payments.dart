import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../config/application_messages.dart';
import '../../../../../config/preferences.dart';
import '../../../../../global/application_constant.dart';
import '../../../../../model/payment.dart';
import '../../../../../model/user.dart';
import '../../../../../res/dimens.dart';
import '../../../../../res/owner_colors.dart';
import '../../../../../res/strings.dart';
import '../../../../../res/styles.dart';
import '../../../../../web_service/links.dart';
import '../../../../../web_service/service_response.dart';
import '../../../components/custom_app_bar.dart';

class Payments extends StatefulWidget {
  const Payments({Key? key}) : super(key: key);

  @override
  State<Payments> createState() => _Payment();
}

class _Payment extends State<Payments> {
  bool _isLoading = false;

  final postRequest = PostRequest();

  Future<List<Map<String, dynamic>>> listPayments() async {
    try {
      final body = {
        "id_usuario": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_PAYMENTS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "Histórico de Pagamentos", isVisibleBackButton: true),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: listPayments(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final firstItem = Payment.fromJson(snapshot.data![0]);

              if (firstItem.rows != 0) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final response = Payment.fromJson(snapshot.data![index]);

                    var methodPayment = "";

                    if (response.tipo_pagamento ==
                        ApplicationConstant.CREDIT_CARD) {
                      methodPayment = "Cartão de Crédito";
                    } else if (response.tipo_pagamento ==
                        ApplicationConstant.TICKET) {
                      methodPayment = "Boleto Bancário";
                    } else if (response.tipo_pagamento ==
                        ApplicationConstant.PIX) {
                      methodPayment = "PIX";
                    } else {
                      methodPayment = "Boleto Bancário(Prazo)";
                    }

                    // Pendente,Aprovado,Rejeitado,Cancelado,Devolvido

                    var _statusColor;

                    switch (response.status_pagamento) {
                      case "Pendente":
                        _statusColor = Colors.blue;
                        break;
                      case "Aprovado":

                        _statusColor = Colors.green;
                        break;
                      case "Rejeitado":

                        _statusColor = Colors.yellow[700];
                        break;
                      case "Cancelado":

                        _statusColor = Colors.red;
                        break;
                      case "Devolvido":

                        _statusColor = OwnerColors.darkGrey;
                        break;
                    }


                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimens.minRadiusApplication),
                      ),
                      margin: EdgeInsets.all(Dimens.minMarginApplication),
                      child: Container(
                        padding: EdgeInsets.all(Dimens.paddingApplication),
                        child: IntrinsicHeight(
                            child: Row(
                          children: [
                            VerticalDivider(
                              color: OwnerColors.colorPrimary,
                              width: 2,
                              thickness: 1.5,
                            ),
                            SizedBox(width: Dimens.marginApplication),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // {
                                  //   "id": 55,
                                  //   "id_usuario": 24,
                                  //   "nome_usuario": "nome teste",
                                  //   "email_usuario": "shini@shini.com",
                                  //   "documento_usuario": "53.877.599/0001-02",
                                  //   "tipo_pagamento": 3,
                                  //   "data_pagamento": "25/05/2023",
                                  //   "url_pagamento": "",
                                  //   "qrcode_pagamento": "00020126580014br.gov.bcb.pix0136b76aa9c2-2ec4-4110-954e-ebfe34f05b61520400005303986540555.005802BR592083466954365557ptFXof6009Sao Paulo62230519mpqrinter13130953086304FC26",
                                  //   "valor_pagamento": " R$ 55,00",
                                  //   "status_pagamento": "Pendente"
                                  // }

                                  Text(
                                    "Transação #" + response.id.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: Dimens.textSize6,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: Dimens.minMarginApplication),
                                  Styles().div_horizontal,
                                  SizedBox(height: Dimens.minMarginApplication),

                                  Text(
                                    "Valor: " +
                                        response.valor_pagamento +
                                        "\n\nStatus do pagamento: " +
                                        response.status_pagamento +
                                        "\nMétodo de pagamento: " +
                                        methodPayment +
                                        "\n\nData: " +
                                        response.data_pagamento,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: Dimens.textSize5,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: Dimens.minMarginApplication),
                                  Align(alignment: AlignmentDirectional.bottomStart, child:
                                  Card(
                                      color: _statusColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(Dimens
                                            .minRadiusApplication),
                                      ),
                                      child: Container(
                                          padding: EdgeInsets.all(Dimens
                                              .minPaddingApplication),
                                          child: Text(
                                            response.status_pagamento.toString(),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize:
                                              Dimens.textSize5,
                                              color: Colors.white,
                                            ),
                                          )))),
                                ],
                              ),
                            )
                          ],
                        )),
                      ),
                    );
                  },
                );
              } else {
                return Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Lottie.network(
                                  height: 160,
                                  'https://assets3.lottiefiles.com/private_files/lf30_cgfdhxgx.json')),
                          SizedBox(height: Dimens.marginApplication),
                          Text(
                            Strings.empty_list,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Dimens.textSize5,
                              color: Colors.black,
                            ),
                          ),
                        ]));
              }
            } else if (snapshot.hasError) {
              return Styles().defaultErrorRequest;
            }
            return Styles().defaultLoading;
          },
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;

      _isLoading = false;
    });
  }
}
