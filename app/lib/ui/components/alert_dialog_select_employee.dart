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
import '../../model/task/task_employee.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class SelectEmployeeAlertDialog extends StatefulWidget {

  final String? id;

  SelectEmployeeAlertDialog({
    Key? key, this.id,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<SelectEmployeeAlertDialog> createState() => _SelectEmployeeAlertDialog();
}

class _SelectEmployeeAlertDialog extends State<SelectEmployeeAlertDialog> {

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


  Future<Map<String, dynamic>> addTaskEmployee(String idTask, String idEmployee) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_funcionario": idEmployee,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.SAVE_TASK_EMPLOYEE, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskEmployee.fromJson(parsedResponse);

      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listTaskEmployeesAll(String idTask, String idCompany) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_empresa": idCompany,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
      await postRequest.sendPostRequest(Links.LIST_TASK_EMPLOYEE_ALL, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = TaskEmployee.fromJson(_map[0]);

      return _map;
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
                        "Adicionar Funcionário",
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
                      future: listTaskEmployeesAll(widget.id!, Preferences.getUserData()!.tipo == 1 ? Preferences.getUserData()!.id.toString(): Preferences.getUserData()!.id_empresa.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final responseItem = TaskEmployee.fromJson(snapshot.data![0]);

                          if (responseItem.rows != 0) {
                            return ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final response = TaskEmployee.fromJson(snapshot.data![index]);

                                return InkWell(
                                    onTap: () => {
                                      addTaskEmployee(widget.id.toString(), response.id.toString())
                                    },
                                    child: Card(
                                      elevation: Dimens.minElevationApplication,
                                      color: Colors.white,
                                      margin: EdgeInsets.all(Dimens.minMarginApplication),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimens.minRadiusApplication),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(Dimens.paddingApplication),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens.minMarginApplication),
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(
                                                        Dimens.minRadiusApplication),
                                                    child: Image.network(
                                                      ApplicationConstant.URL_AVATAR +
                                                          response.avatar.toString(),
                                                      height: 90,
                                                      width: 90,
                                                      errorBuilder: (context, exception,
                                                          stackTrack) =>
                                                          Image.asset(
                                                            'images/main_logo_1.png',
                                                            height: 90,
                                                            width: 90,
                                                          ),
                                                    ))),
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
                                                      fontSize: Dimens.textSize5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: Dimens.minMarginApplication),

                                                ],
                                              ),
                                            ),

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
                    ),
                  ],
                ),
              ),
            ]));
  }
}
