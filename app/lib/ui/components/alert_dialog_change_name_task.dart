import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icontrol/model/task/task_checklist.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/employee.dart';
import '../../model/model.dart';
import '../../model/task/task.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class ChangeNameTaskAlertDialog extends StatefulWidget {
  final String? id;
  final String? idFleet;
  final String? name;

  ChangeNameTaskAlertDialog({
    Key? key,
    this.id,
    this.idFleet,
    this.name,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<ChangeNameTaskAlertDialog> createState() =>
      _ChangeNameTaskAlertDialog();
}

class _ChangeNameTaskAlertDialog extends State<ChangeNameTaskAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  final postRequest = PostRequest();

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    validator = Validator(context: context);

    if (widget.name != null) {
      nameController.text = widget.name.toString();
    }

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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
        "nome": name,
        // "descricao": desc,
        // "checklist": checklist,
        // "status": status,
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
                    "Editar nome da tarefa",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: OwnerColors.colorPrimary, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        hintText: 'Nome',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimens.radiusApplication),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.all(Dimens.textFieldPaddingApplication),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: Dimens.textSize5,
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: Dimens.marginApplication),
                Container(
                  margin: EdgeInsets.only(top: Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Styles().styleDefaultButton,
                    onPressed: () async {
                    /*  if (!validator.validateGenericTextField(
                          nameController.text, "Nome")) return;
*/
                      setState(() {
                        _isLoading = true;
                      });

                      await updateTask(
                          idTask: widget.id.toString(),
                          idFleet: widget.idFleet.toString(),
                          name: nameController.text.toString());

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
                        : Text("Editar",
                            style: Styles().styleDefaultTextButton),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
