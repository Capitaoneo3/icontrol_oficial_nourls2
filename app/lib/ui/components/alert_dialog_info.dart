import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icontrol/model/search.dart';
import 'package:icontrol/res/owner_colors.dart';
import 'package:lottie/lottie.dart';

import '../../global/application_constant.dart';
import '../../res/dimens.dart';
import '../../res/strings.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class InfoAlertDialog extends StatefulWidget {
  String? id;

  InfoAlertDialog({
    Key? key,
    this.id,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<InfoAlertDialog> createState() => _InfoAlertDialogState();
}

class _InfoAlertDialogState extends State<InfoAlertDialog> {
  bool _isLoading = false;

  final postRequest = PostRequest();

  Future<List<Map<String, dynamic>>> listId() async {
    try {
      final body = {
        "id_parceiro": widget.id,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_PARTNER_ID, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = SearchQuery.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              child: Padding(
            padding: const EdgeInsets.all(Dimens.paddingApplication),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: listId(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final responseItem =
                          SearchQuery.fromJson(snapshot.data![0]);

                      if (responseItem.rows != 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(
                                        right: Dimens.minMarginApplication),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                        child: Image.network(
                                          ApplicationConstant.URL_AVATAR +
                                              responseItem.avatar.toString(),
                                          height: 60,
                                          width: 60,
                                          errorBuilder: (context, exception,
                                                  stackTrack) =>
                                              Image.asset(
                                            'images/main_logo_1.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                        ))),
                                SizedBox(width: Dimens.minMarginApplication),
                                Text(
                                  responseItem.nome_fantasia,
                                  style: TextStyle(
                                      fontSize: Dimens.textSize5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: OwnerColors.colorPrimary,
                                ),
                                SizedBox(width: Dimens.marginApplication),
                                Expanded(
                                    child: Text(responseItem.descricao,
                                        style: TextStyle(
                                            fontSize: Dimens.textSize4,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w900))),
                              ],
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: OwnerColors.colorPrimary,
                                ),
                                SizedBox(width: Dimens.marginApplication),
                                Expanded(
                                    child: Text(responseItem.email,
                                        style: TextStyle(
                                            fontSize: Dimens.textSize4,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w900))),
                              ],
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: OwnerColors.colorPrimary,
                                ),
                                SizedBox(width: Dimens.marginApplication),
                                Expanded(
                                    child: Text(responseItem.celular,
                                        style: TextStyle(
                                            fontSize: Dimens.textSize4,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w900))),
                              ],
                            ),
                            SizedBox(height: Dimens.marginApplication),
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  color: OwnerColors.colorPrimary,
                                ),
                                SizedBox(width: Dimens.marginApplication),
                                Expanded(
                                    child: Text(
                                        responseItem.endereco +
                                            ", " +
                                            responseItem.numero +
                                            ", " +
                                            responseItem.bairro +
                                            ", " +
                                            responseItem.cidade +
                                            "/" +
                                            responseItem.estado +
                                            " - " +
                                            responseItem.cep,
                                        style: TextStyle(
                                            fontSize: Dimens.textSize4,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w900))),
                              ],
                            ),
                          ],
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
              ],
            ),
          )),
        ]);
  }
}
