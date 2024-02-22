import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../config/preferences.dart';
import '../../global/application_constant.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';
import '../components/custom_app_bar.dart';

class Plan extends StatefulWidget {
  const Plan({Key? key}) : super(key: key);

  @override
  State<Plan> createState() => _Plan();
}

class _Plan extends State<Plan> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final postRequest = PostRequest();

  Future<List<Map<String, dynamic>>> listAllPlans() async {
    try {
      final body = {"token": ApplicationConstant.TOKEN};

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_PLANS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> loadPlan() async {
    try {
      final body = {
        "id_user": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LOAD_PLAN, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = User.fromJson(parsedResponse);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadHistoryUserPlans() async {
    try {
      final body = {
        "id_user": Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(
          Links.LIST_HISTORY_USER_PLANS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: "Meu plano",
        ),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: FutureBuilder<Map<String, dynamic>>(
              future: loadPlan(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final response = User.fromJson(snapshot.data!);

                  return Stack(children: [
                    SingleChildScrollView(
                        child: Container(
                      padding: EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          Container(
                              margin: EdgeInsets.all(Dimens.marginApplication),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // {
                                  // "plano_id": 2,
                                  // "plano_nome": "Mensal",
                                  // "tempo_total_dias": 30,
                                  // "tempo_restante_dias": 17,
                                  // "tempo_restante_horas": 7,
                                  // "tempo_restante_minutos": 3,
                                  Container(
                                      padding: EdgeInsets.all(
                                          Dimens.minPaddingApplication),
                                      child: IntrinsicHeight(
                                          child: Row(
                                        children: [
                                          Expanded(
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    child: Wrap(
                                                      direction: Axis.vertical,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: OwnerColors
                                                                  .lightGrey),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .minPaddingApplication),
                                                            child: ImageIcon(
                                                              AssetImage(
                                                                  'images/crown.png'),
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Plano atual",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize5,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                            response.plano_nome,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize6,
                                                              color: OwnerColors
                                                                  .colorPrimary,
                                                            )),
                                                      ],
                                                    ),
                                                  ))),
                                          Expanded(
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    child: Wrap(
                                                      direction: Axis.vertical,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: OwnerColors
                                                                  .lightGrey),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .minPaddingApplication),
                                                            child: ImageIcon(
                                                              AssetImage(
                                                                  'images/crown.png'),
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Validade",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize5,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                            response.expiracao_validade,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize6,
                                                              color: OwnerColors
                                                                  .colorPrimary,
                                                            )),
                                                      ],
                                                    ),
                                                  ))),
                                          Expanded(
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    child: Wrap(
                                                      direction: Axis.vertical,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: OwnerColors
                                                                  .lightGrey),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .minPaddingApplication),
                                                            child: ImageIcon(
                                                              AssetImage(
                                                                  'images/crown.png'),
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Restante",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize5,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                            response.tempo_total_dias.toString() + " dia(s)",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize6,
                                                              color: OwnerColors
                                                                  .colorPrimary,
                                                            )),
                                                      ],
                                                    ),
                                                  ))),
                                        ],
                                      ))),
                                  SizedBox(height: Dimens.marginApplication),
                                  Styles().div_horizontal,
                                  SizedBox(height: Dimens.marginApplication),

                                  SizedBox(height: Dimens.minMarginApplication),
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: listAllPlans(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final responseItem =
                                            User.fromJson(snapshot.data![0]);

                                        if (responseItem.rows != 0) {
                                          return ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final response = User.fromJson(
                                                  snapshot.data![index]);

                                              return Card(
                                                elevation: 0.5,
                                                color: OwnerColors.colorPrimary,
                                                margin: EdgeInsets.all(Dimens
                                                    .minMarginApplication),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                child: InkWell(
                                                    onTap: () => {
                                                          Navigator.pushNamed(context, "/ui/method_payment",
                                                              arguments: {
                                                                "id_plan": response.plano_id,
                                                                "days": response.dias,
                                                                "name_plan": response.plano_nome,
                                                                "value": response.valor,
                                                                "desc": response.obs
                                                              })
                                                        },
                                                    child: Container(
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                            padding: EdgeInsets.only(
                                                                left: Dimens
                                                                    .paddingApplication,
                                                                bottom: Dimens
                                                                    .paddingApplication,
                                                                top: Dimens
                                                                    .paddingApplication),
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                    height: Dimens
                                                                        .minMarginApplication),
                                                                Text(
                                                                  response
                                                                      .plano_nome
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          Dimens
                                                                              .textSize7,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  response.dias
                                                                          .toString() +
                                                                      " DIAS",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          Dimens
                                                                              .textSize5,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                          Expanded(
                                                              child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            40))),
                                                            child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                Row(children: [
                                                                  Container(
                                                                      margin: EdgeInsets.only(top: 40, bottom: 40,
                                                                          left: Dimens
                                                                              .marginApplication),
                                                                      child: Text("R\$",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                            'Inter',
                                                                            fontSize:
                                                                            Dimens.textSize6,
                                                                            color:
                                                                            OwnerColors.colorPrimary,
                                                                            fontWeight: FontWeight.bold
                                                                        ),
                                                                      )),

                                                                  Container(
                                                                      margin: EdgeInsets.only(top: 40, bottom: 40,
                                                                      right:
                                                                      30),
                                                                      child:
                                                                      Text(
                                                                        response
                                                                            .valor.replaceAll("R\$ ", ""),
                                                                        style:
                                                                        TextStyle(
                                                                            fontFamily:
                                                                            'Inter',
                                                                            fontSize:
                                                                            Dimens.textSize9,
                                                                            color:
                                                                            OwnerColors.colorPrimary,
                                                                            fontWeight: FontWeight.bold
                                                                        ),
                                                                      )),
                                                                ]),

                                                                ]),
                                                          )),
                                                        ],
                                                      ),
                                                    )),
                                              );
                                            },
                                          );
                                        } else {
                                          return Container(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      20),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                        child: Lottie.network(
                                                            height: 160,
                                                            'https://assets3.lottiefiles.com/private_files/lf30_cgfdhxgx.json')),
                                                    SizedBox(
                                                        height: Dimens
                                                            .marginApplication),
                                                    Text(
                                                      Strings.empty_list,
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize:
                                                            Dimens.textSize5,
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
                                ],
                              ))
                        ],
                      ),
                    )),
                    // Column(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisSize: MainAxisSize.max,
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Container(
                    //         width: double.infinity,
                    //         margin: EdgeInsets.all(Dimens.marginApplication),
                    //         child: ElevatedButton(
                    //             style: Styles().styleDefaultButton,
                    //             onPressed: () {},
                    //             child: Text(
                    //               "Mostrar histórico completo",
                    //               style: Styles().styleDefaultTextButton,
                    //             )),
                    //       ),
                    //     ])
                  ]);
                } else if (snapshot.hasError) {
                  return Styles().defaultErrorRequest;
                }
                return Styles().defaultLoading;
              },
            )));
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;
      _isLoading = false;
    });
  }
}
