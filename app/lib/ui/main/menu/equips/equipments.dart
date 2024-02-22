import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icontrol/ui/components/alert_dialog_equipments_form.dart';
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
import '../../../../model/equipment.dart';
import '../../../components/alert_dialog_generic.dart';
import '../../../components/custom_app_bar.dart';

class Equipments extends StatefulWidget {
  const Equipments({Key? key}) : super(key: key);

  @override
  State<Equipments> createState() => _Equipments();
}

class _Equipments extends State<Equipments> {
  bool _isLoading = false;

  final postRequest = PostRequest();

  Future<List<Map<String, dynamic>>> listEquips() async {
    try {
      final body = {
        "id_user": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_EQUIPMENTS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Equipment.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteEquip(String idEquip) async {
    try {
      final body = {
        "id_equipamento": idEquip,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DELETE_EQUIPMENT, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Equipment.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
            title: "Equipamentos",
            isVisibleBackButton: true,
            isVisibleEquipmentAddButton: true,
            isVisibleOptionsFleetBrandButton: true),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: listEquips(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final responseItem = Equipment.fromJson(snapshot.data![0]);

                  if (responseItem.rows != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final response =
                            Equipment.fromJson(snapshot.data![index]);

                        return InkWell(
                            onTap: () => {},
                            child: Card(
                              elevation: Dimens.minElevationApplication,
                              color: Colors.white,
                              margin:
                                  EdgeInsets.all(Dimens.minMarginApplication),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimens.minRadiusApplication),
                                // side: response.status == 1 ? BorderSide(color: OwnerColors.colorPrimary, width: 2.0) : BorderSide(color: Colors.transparent, width: 0),
                              ),
                              child: Container(
                                padding:
                                    EdgeInsets.all(Dimens.paddingApplication),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Container(
                                    //     margin: EdgeInsets.only(
                                    //         right: Dimens.minMarginApplication),
                                    //     child: ClipRRect(
                                    //         borderRadius: BorderRadius.circular(
                                    //             Dimens.minRadiusApplication),
                                    //         child: Image.network(
                                    //           ApplicationConstant.URL_FLEETS +
                                    //               response.url.toString(),
                                    //           height: 90,
                                    //           width: 90,
                                    //           errorBuilder: (context, exception,
                                    //               stackTrack) =>
                                    //               Image.asset(
                                    //                 'images/main_logo_1.png',
                                    //                 height: 90,
                                    //                 width: 90,
                                    //               ),
                                    //         ))),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            response.nome,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: Dimens.textSize6,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  Dimens.minMarginApplication),
                                          // Text(
                                          //   response.status.toString() == "1" ? "Status: Ativo" : "Status: Inativo",
                                          //   maxLines: 2,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   style: TextStyle(
                                          //     fontFamily: 'Inter',
                                          //     fontSize: Dimens.textSize4,
                                          //     color: Colors.black,
                                          //   ),
                                          // ),
                                          Text(
                                            "Marca: " +
                                                response.marca_nome +
                                                "\nModelo: " +
                                                response.modelo_nome +
                                                "\n\nAno: " +
                                                response.ano.toString() +
                                                "\nSérie: " +
                                                response.serie +
                                                "\n\nProprietário: " +
                                                response.proprietario +
                                                "\nPlaca: " +
                                                response.placa +
                                                "\n\nHorímetro: " +
                                                response.horimetro +
                                                "\n\nData do cadastro: " +
                                                response.data_cadastro,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: Dimens.textSize4,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                        margin: EdgeInsets.all(2),
                                        child: InkWell(
                                            onTap: () async {
                                              final result =
                                                  await showModalBottomSheet<
                                                          dynamic>(
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape: Styles()
                                                          .styleShapeBottomSheet,
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      builder: (BuildContext
                                                          context) {
                                                        return EquipmentFormAlertDialog(
                                                          id: response.id
                                                              .toString(),
                                                          id_brand: response
                                                              .marca
                                                              .toString(),
                                                          id_model: response
                                                              .modelo
                                                              .toString(),
                                                          brand: response
                                                              .marca_nome
                                                              .toString(),
                                                          model: response
                                                              .modelo_nome
                                                              .toString(),
                                                          name: response.nome
                                                              .toString(),
                                                          year: response.ano
                                                              .toString(),
                                                          series: response.serie
                                                              .toString(),
                                                          schedule: response
                                                              .horimetro
                                                              .toString(),
                                                          owner: response
                                                              .proprietario
                                                              .toString(),
                                                          tag: response.placa
                                                              .toString(),
                                                          status: "1",
                                                        );
                                                      });
                                              if (result == true) {
                                                setState(() {});
                                              }
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(Dimens
                                                        .minRadiusApplication),
                                              ),
                                              color: OwnerColors.darkGrey,
                                              child: Padding(
                                                padding: EdgeInsets.all(Dimens
                                                    .minPaddingApplication),
                                                child: Icon(Icons.edit_note,
                                                    size: 20,
                                                    color: Colors.white),
                                              ),
                                            ))),
                                    Container(
                                        margin: EdgeInsets.all(2),
                                        child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<dynamic>(
                                                isScrollControlled: true,
                                                context: context,
                                                shape: Styles()
                                                    .styleShapeBottomSheet,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                builder:
                                                    (BuildContext context) {
                                                  return GenericAlertDialog(
                                                      title: Strings.attention,
                                                      content:
                                                          "Tem certeza que deseja remover este equipamento?",
                                                      btnBack: TextButton(
                                                          child: Text(
                                                            Strings.no,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                      btnConfirm: TextButton(
                                                          child:
                                                              Text(Strings.yes),
                                                          onPressed: () {
                                                            deleteEquip(response
                                                                .id
                                                                .toString());
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }));
                                                },
                                              );
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(Dimens
                                                        .minRadiusApplication),
                                              ),
                                              color: Colors.red,
                                              child: Padding(
                                                padding: EdgeInsets.all(Dimens
                                                    .minPaddingApplication),
                                                child: Icon(Icons.remove,
                                                    size: 20,
                                                    color: Colors.white),
                                              ),
                                            ))),
                                  ],
                                ),
                              ),
                            ));
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
            )));
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;

      _isLoading = false;
    });
  }
}
