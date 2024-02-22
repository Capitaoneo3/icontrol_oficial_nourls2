import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../../../../global/application_constant.dart';
import '../../../../res/dimens.dart';
import '../../../../res/owner_colors.dart';
import '../../../../res/strings.dart';
import '../../../../res/styles.dart';
import '../../../../web_service/links.dart';
import '../../../../web_service/service_response.dart';
import '../../../config/application_messages.dart';
import '../../components/custom_app_bar.dart';
import '../home.dart';

class Success extends StatefulWidget {
  const Success({Key? key}) : super(key: key);

  @override
  State<Success> createState() => _Success();
}

class _Success extends State<Success> {
  bool _isLoading = false;

  late String _base64;
  late String _qrCodeClipboard;
  late String _typePaymentName;

  late String _totalValue;

  late String _barCode;

  final postRequest = PostRequest();

  @override
  Widget build(BuildContext context) {
    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _base64 = data['base64'];
    _qrCodeClipboard = data['qrCodeClipboard'];

    _typePaymentName = data['payment_type'];

    _barCode = data['barCode'];

    _totalValue = data['total_value'];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: "Compra finalizada!",
          // isVisibleBackButton: true,
        ),
        body: Stack(children: [
          SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(Dimens.marginApplication),
                padding: EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Lottie.network(
                            height: 140,
                            'https://assets1.lottiefiles.com/packages/lf20_o3kwwgtn.json')),
                    // SizedBox(height: Dimens.marginApplication),
                    // Text(
                    //   "Detalhes do pedido #",
                    //   style: TextStyle(
                    //     fontFamily: 'Inter',
                    //     fontSize: Dimens.textSize6,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // // ),
                    // SizedBox(height: Dimens.marginApplication),
                    // Styles().div_horizontal,
                    SizedBox(height: Dimens.marginApplication),
                    // Text(
                    //   "Valores:",
                    //   style: TextStyle(
                    //     fontFamily: 'Inter',
                    //     fontSize: Dimens.textSize5,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    SizedBox(height: Dimens.minMarginApplication),
                    Column(children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Valor total",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            _totalValue.toString(),
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize7,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ]),
                    SizedBox(height: Dimens.marginApplication),
                    Styles().div_horizontal,
                    SizedBox(height: Dimens.marginApplication),
                    Text(
                      "Pagamento",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: Dimens.textSize5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: Dimens.minMarginApplication),
                    Visibility(
                        visible: _typePaymentName == "Cartão de crédito",
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/credit_card.png',
                                            height: 24, width: 24))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Cartão de crédito",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )),

                              ],
                            ),

                            SizedBox(height: Dimens.marginApplication),
                            // Text(
                            //   "Tipo de pagamento: $_typePaymentName",
                            //   style: TextStyle(
                            //     fontFamily: 'Inter',
                            //     fontSize: Dimens.textSize5,
                            //     color: Colors.black,
                            //   ),
                            // ),
                          ],
                        )),
                    Visibility(
                        visible: _typePaymentName == "Boleto bancário",
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/ticket.png',
                                            height: 24, width: 24))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Boleto bancário",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )),

                              ],
                            ),

                            SizedBox(height: Dimens.marginApplication),
                            Text(
                              /*"Tipo de pagamento: $_typePaymentName" +
                              "\n\n" +*/
                              "Para pagar pelo Internet Banking. copie a linha digitável ou escaneie o código de barras." +
                                  "\n\n" +
                                  "Se o pagamento é feito de segunda a sexta, é creditado no dia seguinte. Se você pagar no fim de semana, será creditado na terça-feira.",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize5,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Center(
                                child: Container(
                                  height: 100,
                                  child: SfBarcodeGenerator(
                                      value: _barCode, symbology: Code128C()),
                                )),
                          ],
                        )),
                    Visibility(
                        visible: _typePaymentName == "PIX",
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/qr_code.png',
                                            height: 24, width: 24))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "PIX",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )),

                              ],
                            ),

                            SizedBox(height: Dimens.marginApplication),
                            Text(
                              /*"Tipo de pagamento: $_typePaymentName" +
                              "\n\n" +*/
                              "Copie este código para pagar" +
                                  "\n\n" +
                                  "1. Acesse seu Internet Banking ou app de pagamentos." +
                                  "\n\n" +
                                  "2. Escolha pagar via Pix/QR Code" +
                                  "\n\n" +
                                  "3. Escaneie o seguinte código:",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize5,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Image.memory(
                                height: 200,
                                Base64Decoder().convert(_base64.toString()))
                          ],
                        )),
                    Visibility(
                        visible: _typePaymentName == "Boleto à prazo",
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/calendar.png',
                                            height: 24, width: 24))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Boleto à prazo",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )),

                              ],
                            ),

                            SizedBox(height: Dimens.marginApplication),
                            // Text(
                            //   "Tipo de pagamento: $_typePaymentName",
                            //   style: TextStyle(
                            //     fontFamily: 'Inter',
                            //     fontSize: Dimens.textSize5,
                            //     color: Colors.black,
                            //   ),
                            // ),
                          ],
                        )),
                  ],
                ),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                  visible: _typePaymentName == "PIX",
                  child: Container(
                      margin: EdgeInsets.all(Dimens.minMarginApplication),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: _qrCodeClipboard));
                            ApplicationMessages(context: context)
                                .showMessage("Link Copiado!");
                          },
                          style: Styles().styleAlternativeButton,
                          child: Container(
                              child: Text("Copiar chave",
                                  textAlign: TextAlign.center,
                                  style: Styles().styleDefaultTextButton))))),
              Visibility(
                  visible: _typePaymentName == "Boleto bancário",
                  child: Container(
                      margin: EdgeInsets.all(Dimens.minMarginApplication),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: _barCode));
                            ApplicationMessages(context: context)
                                .showMessage("Link Copiado!");
                          },
                          style: Styles().styleAlternativeButton,
                          child: Container(
                              child: Text("Copiar",
                                  textAlign: TextAlign.center,
                                  style: Styles().styleDefaultTextButton))))),
              Container(
                  margin: EdgeInsets.all(Dimens.minMarginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                            ModalRoute.withName("/ui/home"));
                      },
                      style: Styles().styleDefaultButton,
                      child: Container(
                          child: Text("Ok",
                              textAlign: TextAlign.center,
                              style: Styles().styleDefaultTextButton))))
            ],
          )
        ]));
  }
}
