import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icontrol/model/task/task_attachment.dart';
import 'package:lottie/lottie.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/employee.dart';
import '../../model/model.dart';
import '../../model/task/task.dart';
import '../../model/task/task_employee.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class SelectStatusAlertDialog extends StatefulWidget {
  final String? id;
  final String? idFleet;

  SelectStatusAlertDialog({
    Key? key,
    this.id,
    this.idFleet,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<SelectStatusAlertDialog> createState() => _SelectStatusAlertDialog();
}

class _SelectStatusAlertDialog extends State<SelectStatusAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  final postRequest = PostRequest();

  @override
  void initState() {
    validator = Validator(context: context);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> listStatus() async {
    try {
      final body = {
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_STATUS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Task.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> updateTask(
      {String? idTask,
      String? idFleet,
      String? idEquip,
      String? name,
      String? desc,
      String? checklist,
      String? status}) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_frota": idFleet,
        // "id_equipamento": idEquip,
        // "nome": name,
        // "descricao": desc,
        // "checklist": checklist,
        "status": status,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.UPDATE_TASK, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      Navigator.of(context).pop(true);

      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
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
                Container(
                  width: double.infinity,
                  child: Text(
                    "Editar status",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: listStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final responseItem = Task.fromJson(snapshot.data![0]);

                      if (responseItem.rows != 0) {
                        return ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {

                            final response = Task.fromJson(snapshot.data![index]);

                            var color = response.cor.replaceAll("#", "");

                            return InkWell(
                                onTap: () => {
                                      updateTask(
                                          idTask: widget.id.toString(),
                                          idFleet: widget.idFleet.toString(),
                                          status: response.id.toString())
                                    },
                                child: Container(
                                    margin: EdgeInsets.all(4),
                                    child: Card(
                                        color: Color(int.parse("0xFF$color")),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimens.minRadiusApplication),
                                        ),
                                        child: Container(
                                            padding: EdgeInsets.all(
                                                Dimens.minPaddingApplication),
                                            child: Text(
                                              response.nome,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                color: Colors.white,
                                              ),
                                            )))));
                          },
                        );
                      } else {
                        return Container();
                      }
                    } else if (snapshot.hasError) {
                      return Styles().defaultErrorRequest;
                    }
                    return Styles().defaultLoading;
                  },
                ),
              ],
            ),
          ),
        ]));
  }
}
