import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:icontrol/model/task/task_checklist.dart';
import 'package:intl/intl.dart';

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

class UpdateTaskItemAlertDialog extends StatefulWidget {
  final String? id;
  final String? name;
  final String? hourMeter;
  final String? actualDate;


  UpdateTaskItemAlertDialog({
    Key? key,
    this.id,
    this.name,
    this.hourMeter,
    this.actualDate,

  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<UpdateTaskItemAlertDialog> createState() =>
      _UpdateTaskItemAlertDialog();
}

class _UpdateTaskItemAlertDialog extends State<UpdateTaskItemAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  String date = "00/00/0000 00:00";

  final postRequest = PostRequest();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController hourMeterController = TextEditingController();

  @override
  void initState() {
    validator = Validator(context: context);

    nameController.text = widget.name!;
    hourMeterController.text = widget.hourMeter!;


    if (widget.actualDate != null) {
      date = widget.actualDate!;
    }

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> updateTaskItem(
      {String? id,
        String? name,
      String? date, String? hourMeter}) async {
    try {
      final body = {
        "id_check_item": id,
        "nome": name,
        "previsao": date,
        "horimetro": hourMeter,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.UPDATE_TASK_CHECKLIST_ITEM, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskChecklist.fromJson(parsedResponse);

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Editar item",
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
                SizedBox(
                    height: Dimens.minMarginApplication),
                TextField(
                  controller: hourMeterController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Horimetro',
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
                SizedBox(
                    height: Dimens.marginApplication),
                Container(
                    height: 40,
                    child: ElevatedButton(
                        style: Styles()
                            .styleAlternativeButton,
                        onPressed: () {
                          DatePicker.showDatePicker(
                            context,
                            dateFormat: 'dd MMMM yyyy HH:mm',
                            initialDateTime: DateTime.now(),
                            minDateTime: DateTime(2000),
                            maxDateTime: DateTime(3000),
                            onMonthChangeStartWithFirstDate: true,
                            onConfirm: (dateTime, List<int> index) {
                              DateTime selectdate = dateTime;
                              final selIOS = DateFormat('dd/MM/yyyy HH:mm').format(selectdate);
                              print(selIOS);

                              date = selIOS;

                            },
                          );
                        },
                        child: Text(
                          "Data de entrega",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize:
                              Dimens.textSize4,
                              color: Colors.white),
                        ))),
                SizedBox(
                    height: Dimens.minMarginApplication),
                Card(
                    color: OwnerColors.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 4),
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Container(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Dimens.textSize4,
                                color: Colors.white,
                              ),
                            ))
                      ],
                    )),
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

                      await updateTaskItem(id: widget.id.toString(), name: nameController.text.toString(), date: date, hourMeter: hourMeterController.text.toString());

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
