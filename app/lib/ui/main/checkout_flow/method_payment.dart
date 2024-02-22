import 'package:flutter/material.dart';

import '../../../global/application_constant.dart';
import '../../../res/dimens.dart';
import '../../../res/owner_colors.dart';
import '../../../res/styles.dart';
import '../../components/custom_app_bar.dart';

class MethodPayment extends StatefulWidget {
  const MethodPayment({Key? key}) : super(key: key);

  @override
  State<MethodPayment> createState() => _MethodPayment();
}

class _MethodPayment extends State<MethodPayment> {
  bool _isLoading = false;

  late int _idPlan;
  late String _typePayment;
  late int _days;
  late String _typePlan;
  late String _value;
  late String _desc;

  void goToCheckout(String typePayment) {


    Navigator.pushNamed(
        context, "/ui/checkout",
        arguments: {
          "type_payment": typePayment,
          "id_plan": _idPlan,
          "days": _days,
          "name_plan": _typePlan,
          "value": _value,
          "desc": _desc
        });
  }

  @override
  Widget build(BuildContext context) {
    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _typePayment = data['type_payment'];
    _idPlan = data['id_plan'];
    _days= data['days'];
    _value = data['value'];
    _typePlan = data['name_plan'];
    _desc = data['desc'];


    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
            title: "Escolha um Método de pagamento", isVisibleBackButton: true),
        body: Container(
            child: SingleChildScrollView(
                child: Column(children: [
                  InkWell(
                      onTap: () {
                        goToCheckout(ApplicationConstant.PIX.toString());
                      },
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(Dimens.minRadiusApplication),
                          ),
                          margin: EdgeInsets.all(Dimens.minMarginApplication),
                          child: Container(
                            padding: EdgeInsets.all(Dimens.minPaddingApplication),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/qr_code.png',
                                          height: 50, width: 50, color: Colors.black54,))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        SizedBox(
                                          height: Dimens.minMarginApplication,
                                        ),
                                        Text(
                                          "Liberação das moedas de forma instantânea.",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black38,
                                  size: 20,
                                ),
                              ],
                            ),
                          ))),
                  InkWell(
                      onTap: () {

                        goToCheckout(ApplicationConstant.CREDIT_CARD.toString());

                      },
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(Dimens.minRadiusApplication),
                          ),
                          margin: EdgeInsets.all(Dimens.minMarginApplication),
                          child: Container(
                            padding: EdgeInsets.all(Dimens.minPaddingApplication),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/credit_card.png',
                                            height: 50, width: 50, color: Colors.black54))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Novo Cartão de Crédito",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: Dimens.minMarginApplication,
                                        ),
                                        Text(
                                          "Pagamento de forma segura e instantânea.",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black38,
                                  size: 20,
                                ),
                              ],
                            ),
                          ))),
                  InkWell(
                      onTap: () {

                        goToCheckout(ApplicationConstant.TICKET.toString());
                      },
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(Dimens.minRadiusApplication),
                          ),
                          margin: EdgeInsets.all(Dimens.minMarginApplication),
                          child: Container(
                            padding: EdgeInsets.all(Dimens.minPaddingApplication),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.asset('images/ticket.png',
                                            height: 50, width: 50, color: Colors.black54))),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Boleto",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: Dimens.minMarginApplication,
                                        ),
                                        Text(
                                          "Será aprovado em 1 a 2 dias úteis.",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: Dimens.textSize4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black38,
                                  size: 20,
                                ),
                              ],
                            ),
                          ))),

                  // Visibility(/*visible: _profileResponse?.saldo_aprovado == 1, */child:
                  // InkWell(
                  //     onTap: () {
                  //
                  //       goToCheckout(ApplicationConstant.TICKET_IN_TERM.toString());
                  //
                  //     },
                  //     child: Card(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius:
                  //           BorderRadius.circular(Dimens.minRadiusApplication),
                  //         ),
                  //         margin: EdgeInsets.all(Dimens.minMarginApplication),
                  //         child: Container(
                  //           padding: EdgeInsets.all(Dimens.minPaddingApplication),
                  //           child: Row(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: [
                  //               Container(
                  //                   margin: EdgeInsets.all(Dimens.minMarginApplication),
                  //                   child: ClipRRect(
                  //                       borderRadius: BorderRadius.circular(
                  //                           Dimens.minRadiusApplication),
                  //                       child: Image.asset('images/calendar.png',
                  //                           height: 50, width: 50, color: Colors.black54))),
                  //               Expanded(
                  //                   child: Column(
                  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                     crossAxisAlignment: CrossAxisAlignment.start,
                  //                     children: [
                  //                       Text(
                  //                         "Boleto à prazo",
                  //                         style: TextStyle(
                  //                           fontFamily: 'Inter',
                  //                           fontSize: Dimens.textSize5,
                  //                           color: Colors.black,
                  //                         ),
                  //                       ),
                  //                       SizedBox(
                  //                         height: Dimens.minMarginApplication,
                  //                       ),
                  //                       Text(
                  //                         "Parcele o valor total da compra.",
                  //                         style: TextStyle(
                  //                           fontFamily: 'Inter',
                  //                           fontSize: Dimens.textSize4,
                  //                           color: Colors.black87,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   )),
                  //               Icon(
                  //                 Icons.arrow_forward_ios,
                  //                 color: Colors.black38,
                  //                 size: 20,
                  //               ),
                  //
                  //             ],
                  //           ),
                  //         ))))
                ]))));
  }
}
