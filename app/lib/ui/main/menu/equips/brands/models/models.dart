import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../config/preferences.dart';
import '../../../../../../global/application_constant.dart';
import '../../../../../../model/brand.dart';
import '../../../../../../model/model.dart';
import '../../../../../../res/dimens.dart';
import '../../../../../../res/owner_colors.dart';
import '../../../../../../res/strings.dart';
import '../../../../../../res/styles.dart';
import '../../../../../../web_service/links.dart';
import '../../../../../../web_service/service_response.dart';
import '../../../../../components/alert_dialog_generic.dart';
import '../../../../../components/alert_dialog_model_form.dart';
import '../../../../../components/custom_app_bar.dart';


class Models extends StatefulWidget {
  const Models({Key? key}) : super(key: key);

  @override
  State<Models> createState() => _Models();
}

class _Models extends State<Models> {
  bool _isLoading = false;
  int _idBrand = 0;

  final postRequest = PostRequest();

  Future<List<Map<String, dynamic>>> listModels(String idBrand) async {
    try {
      final body = {
        "id_marca": idBrand,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
      await postRequest.sendPostRequest(Links.LIST_MODELS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Model.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteModel(String idModel) async {
    try {
      final body = {
        "id_modelo": idModel,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.DELETE_MODEL, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Model.fromJson(parsedResponse);


      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _idBrand = data['id_brand'];
    
    
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(title: "Modelos", isVisibleBackButton: true, isVisibleModelAddButton: true, idBrand: _idBrand.toString(),),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                listModels(_idBrand.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final responseItem = Brand.fromJson(snapshot.data![0]);

                    if (responseItem.rows != 0) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final response = Brand.fromJson(snapshot.data![index]);

                          return InkWell(
                              onTap: () => {

                              },
                              child: Card(
                                elevation: Dimens.minElevationApplication,
                                color: Colors.white,
                                margin: EdgeInsets.all(Dimens.minMarginApplication),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimens.minRadiusApplication),
                                  side: response.status == 1 ? BorderSide(color: OwnerColors.colorPrimary, width: 2.0) : BorderSide(color: Colors.transparent, width: 0),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(Dimens.paddingApplication),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
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
                                                height: Dimens.minMarginApplication),
                                            Text(
                                              response.status.toString() == "1" ? "Status: Ativo" : "Status: Inativo",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                                    isScrollControlled:
                                                    true,
                                                    context: context,
                                                    shape: Styles()
                                                        .styleShapeBottomSheet,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    builder:
                                                        (BuildContext
                                                    context) {
                                                      return ModelFormAlertDialog(
                                                          id: response
                                                              .id
                                                              .toString(),
                                                          idBrand: _idBrand.toString(),
                                                          name: response
                                                              .nome,
                                                          status: response
                                                              .status.toString());
                                                    });
                                                if (result == true) {
                                                  setState(() {

                                                  });
                                                }
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      Dimens.minRadiusApplication),
                                                ),
                                                color: OwnerColors.darkGrey,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      Dimens.minPaddingApplication),
                                                  child: Icon(Icons.edit_note,
                                                      size: 20, color: Colors.white),
                                                ),
                                              ))),
                                      Container(
                                          margin: EdgeInsets.all(2),
                                          child: InkWell(
                                              onTap: () {
                                                showModalBottomSheet<
                                                    dynamic>(
                                                  isScrollControlled:
                                                  true,
                                                  context: context,
                                                  shape: Styles()
                                                      .styleShapeBottomSheet,
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  builder:
                                                      (BuildContext
                                                  context) {
                                                    return GenericAlertDialog(
                                                        title: Strings
                                                            .attention,
                                                        content:
                                                        "Tem certeza que deseja remover este modelo?",
                                                        btnBack:
                                                        TextButton(
                                                            child:
                                                            Text(
                                                              Strings.no,
                                                              style:
                                                              TextStyle(
                                                                fontFamily: 'Inter',
                                                                color: Colors.black54,
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () {
                                                              Navigator.of(context).pop();
                                                            }),
                                                        btnConfirm:
                                                        TextButton(
                                                            child: Text(Strings
                                                                .yes),
                                                            onPressed:
                                                                () {
                                                              deleteModel(response.id.toString());
                                                              Navigator.of(context).pop();
                                                            }));
                                                  },
                                                );
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      Dimens.minRadiusApplication),
                                                ),
                                                color: Colors.red,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      Dimens.minPaddingApplication),
                                                  child: Icon(Icons.remove,
                                                      size: 20, color: Colors.white),
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
              ),)));
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;

      _isLoading = false;
    });
  }
}
