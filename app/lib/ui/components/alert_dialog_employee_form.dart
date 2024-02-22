import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/employee.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class EmployeeFormAlertDialog extends StatefulWidget {

  final String? id;
  final String? id_company;
  final String? name;
  final String? email;
  final String? cellphone;
  final String? cpf;
  final String? birth;
  final String? status;

  EmployeeFormAlertDialog({
    Key? key, this.id, this.id_company, this.name, this.email, this.cellphone, this.cpf, this.birth, this.status
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<EmployeeFormAlertDialog> createState() => _EmployeeFormAlertDialog();
}

class _EmployeeFormAlertDialog extends State<EmployeeFormAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  bool light = false;

  final postRequest = PostRequest();

  @override
  void initState() {
    validator = Validator(context: context);

    if (widget.id != null) {
      nameController.text = widget.name!;
      emailController.text = widget.email!;
      cellphoneController.text = widget.cellphone!;
      cpfController.text = widget.cpf!;
      birthController.text = widget.birth!;

      if (widget.status == "1") {
        light = true;
      } else {
        light = false;
      }
    }

    super.initState();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cellphoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController birthController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cellphoneController.dispose();
    cpfController.dispose();
    birthController.dispose();
    super.dispose();
  }


  Future<Map<String, dynamic>> updateEmployee(String idCompany, String idEmployee, String name, String email, String cellphone, String cpf, String birth, String status) async {
    try {
      final body = {
        "id_empresa": idCompany,
        "id_funcionario": idEmployee,
        "nome": name,
        "email": email,
        "celular": cellphone,
        "cpf": cpf,
        "data_nascimento": birth,
        "status": status,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.EDIT_EMPLOYEE, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Employee.fromJson(parsedResponse);
      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> saveEmployee(String idCompany, String name, String email, String cellphone, String cpf, String birth) async {
    try {
      final body = {
        "id_empresa": idCompany,
        "nome": name,
        "email": email,
        "celular": cellphone,
        "cpf": cpf,
        "data_nascimento": birth,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.SAVE_EMPLOYEE, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Employee.fromJson(_map[0]);
      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

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
                    widget.id != null ?  "Editar funcionário" :"Adicionar funcionário",
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
                Styles().div_horizontal,
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'E-mail',
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
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Dimens.textSize5,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: cellphoneController,
                  inputFormatters: [Masks().cellphoneMask()],
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Celular',
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
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Dimens.textSize5,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: cpfController,
                  inputFormatters: [Masks().cpfMask()],
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'CPF',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(Dimens.radiusApplication),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(
                        Dimens.textFieldPaddingApplication),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Dimens.textSize5,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: birthController,
                  inputFormatters: [Masks().birthMask()],
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Data de nascimento',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(Dimens.radiusApplication),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(
                        Dimens.textFieldPaddingApplication),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Dimens.textSize5,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                Styles().div_horizontal,
                Visibility(visible: widget.id != null, child: Row(children: [
                  Text(
                    "Status (Inativo / Ativo)",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize5,
                      color: Colors.black,
                    ),
                  ),
                  Switch(
                    value: light,
                    onChanged: (bool value) {
                      setState(() {
                        light = value;
                      });
                    },
                  ),
                ],)),
                SizedBox(height: Dimens.marginApplication),
                Container(
                  margin: EdgeInsets.only(top: Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Styles().styleDefaultButton,
                    onPressed: () async {
                    /*  if (!validator.validateGenericTextField(
                          nameController.text, "Nome")) return;
                      if (!validator.validateEmail(emailController.text)) return;
                      if (!validator.validateCellphone(cellphoneController.text)) return;
                      if (!validator.validateCPF(cpfController.text)) return;

                      if (birthController.text.isNotEmpty && birthController.text != "00/00/0000") {
                        if (!validator.validateBirth(birthController.text, "dd/MM/yyyy")) return;
                      }*/

                      setState(() {
                        _isLoading = true;
                      });

                      if (widget.id != null) {
                        await updateEmployee(
                            Preferences.getUserData()!.id.toString(),
                            widget.id!,
                            nameController.text.toString(),
                            emailController.text.toString(),
                            cellphoneController.text.toString(),
                            cpfController.text.toString(),
                            birthController.text.toString(),
                            light ? "1" : "2");
                      } else {
                        await saveEmployee(
                            Preferences.getUserData()!.id.toString(),
                            nameController.text.toString(),
                            emailController.text.toString(),
                            cellphoneController.text.toString(),
                            cpfController.text.toString(),
                            birthController.text.toString());
                      }

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
                        : Text("Salvar",
                            style: Styles().styleDefaultTextButton),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
