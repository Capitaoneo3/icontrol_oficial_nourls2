import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/employee.dart';
import '../../model/equipment.dart';
import '../../model/model.dart';
import '../../model/task/task.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class AddTaskAlertDialog extends StatefulWidget {


  Container? btnConfirm;
  TextEditingController categoryController;
  TextEditingController titleController;
  TextEditingController descController;

  AddTaskAlertDialog({
    Key? key,
    required this.categoryController,
    required this.titleController,
    required this.descController,
    required this.btnConfirm,
  });

  @override
  State<AddTaskAlertDialog> createState() => _AddTaskAlertDialog();
}

class _AddTaskAlertDialog extends State<AddTaskAlertDialog> {

  String currentSelectedValueCategory = "Selecione";

  int? _categoryPosition;

  final postRequest = PostRequest();

  @override
  void initState() {

    widget.categoryController.text = "";
    widget.titleController.text = "";
    widget.descController.text = "";

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                    /*"Insira os dados da tarefa"*/"Selecione o equipamento",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // SizedBox(height: Dimens.marginApplication),
                // TextField(
                //   controller: widget.titleController,
                //   decoration: InputDecoration(
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: BorderSide(
                //           color: OwnerColors.colorPrimary, width: 1.5),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.grey, width: 1.0),
                //     ),
                //     hintText: 'Título da tarefa',
                //     hintStyle: TextStyle(color: Colors.grey),
                //     border: OutlineInputBorder(
                //       borderRadius:
                //           BorderRadius.circular(Dimens.radiusApplication),
                //       borderSide: BorderSide.none,
                //     ),
                //     filled: true,
                //     fillColor: Colors.white,
                //     contentPadding:
                //         EdgeInsets.all(Dimens.textFieldPaddingApplication),
                //   ),
                //   keyboardType: TextInputType.text,
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontSize: Dimens.textSize5,
                //   ),
                // ),
                // SizedBox(height: Dimens.marginApplication),
                // SizedBox(
                //     height: 100.0,
                //     child: TextField(
                //       expands: true,
                //       minLines: null,
                //       maxLines: null,
                //       controller: widget.descController,
                //       decoration: InputDecoration(
                //         focusedBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //               color: OwnerColors.colorPrimary, width: 1.5),
                //         ),
                //         enabledBorder: OutlineInputBorder(
                //           borderSide:
                //           BorderSide(color: Colors.grey, width: 1.0),
                //         ),
                //         hintText: 'Descrição...',
                //         hintStyle: TextStyle(color: Colors.grey),
                //         border: OutlineInputBorder(
                //           borderRadius:
                //           BorderRadius.circular(Dimens.radiusApplication),
                //           borderSide: BorderSide.none,
                //         ),
                //         filled: true,
                //         fillColor: Colors.white,
                //         contentPadding:
                //         EdgeInsets.all(Dimens.textFieldPaddingApplication),
                //       ),
                //       keyboardType: TextInputType.text,
                //       style: TextStyle(
                //         color: Colors.grey,
                //         fontSize: Dimens.textSize5,
                //       ),
                //     )),
                //
                // SizedBox(height: Dimens.marginApplication),
                // Styles().div_horizontal,

                SizedBox(height: Dimens.marginApplication),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: listEquips(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final responseItem =
                          Equipment.fromJson(snapshot.data![0]);

                      if (responseItem.rows != 0) {
                        var categoryList = <String>[];

                        categoryList.add("Selecione");
                        for (var i = 0; i < snapshot.data!.length; i++) {
                          categoryList
                              .add(Equipment.fromJson(snapshot.data![i]).nome);
                        }

                        return InputDecorator(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0))),
                            child: Container(
                                child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  "Selecione",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: OwnerColors.colorPrimary,
                                  ),
                                ),
                                value: currentSelectedValueCategory,
                                isDense: true,
                                onChanged: (newValue) {
                                  setState(() {
                                    currentSelectedValueCategory = newValue!;

                                    if (categoryList.indexOf(newValue) > 0) {
                                      _categoryPosition =
                                          categoryList.indexOf(newValue) - 1;
                                      widget.categoryController.text = Equipment.fromJson(snapshot
                                              .data![_categoryPosition!])
                                          .id
                                          .toString();
                                    } else {
                                      widget.categoryController.text = "";
                                    }

                                    print(currentSelectedValueCategory +
                                        _categoryPosition.toString() +
                                        widget.categoryController.text.toString());
                                  });
                                },
                                items: categoryList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: OwnerColors.colorPrimary,
                                        )),
                                  );
                                }).toList(),
                              ),
                            )));
                      } else {
                        return Text(textAlign: TextAlign.start, "Não existem equipamentos registrados, adicione-os indo até o menu de equipamentos.");
                      }
                    } else if (snapshot.hasError) {
                      return Styles().defaultErrorRequest;
                    }
                    return Styles().defaultLoading;
                  },
                ),
                SizedBox(height: Dimens.marginApplication),
                widget.btnConfirm!

              ],
            ),
          ),
        ]));
  }
}
