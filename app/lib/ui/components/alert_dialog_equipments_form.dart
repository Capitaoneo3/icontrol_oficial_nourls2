import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/brand.dart';
import '../../model/employee.dart';
import '../../model/equipment.dart';
import '../../model/model.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';

class EquipmentFormAlertDialog extends StatefulWidget {

  final String? id;
  final String? id_brand;
  final String? id_model;
  final String? brand;
  final String? model;
  final String? name;
  final String? year;
  final String? series;
  final String? schedule;
  final String? owner;
  final String? tag;
  final String? status;

  EquipmentFormAlertDialog(
      {Key? key,
      this.id,
      this.id_brand,
      this.id_model,
      this.brand,
      this.model,
      this.name,
      this.year,
      this.series,
      this.schedule,
      this.owner,
      this.tag,
      this.status});

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<EquipmentFormAlertDialog> createState() => _EquipmentFormAlertDialog();
}

class _EquipmentFormAlertDialog extends State<EquipmentFormAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  String currentSelectedValueCategory = "Selecione";
  String currentSelectedValueSubcategory = "Selecione";

  int? _categoryPosition;
  int? _subcategoryPosition;

  String? _idCategory;
  String? _idSubcategory;

  final postRequest = PostRequest();

  Future<Map<String, dynamic>> saveEquip(
      String idBrand,
      String idModel,
      String name,
      String status,
      String year,
      String series,
      String hour,
      String tag,
      String owner) async {
    try {
      final body = {
        "id_marca": idBrand,
        "id_modelo": idModel,
        "nome": name,
        "ano": year,
        "serie": series,
        "horimetro": hour,
        "proprietario": owner,
        "placa": tag,
        "status": status,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.SAVE_EQUIPMENT, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Equipment.fromJson(parsedResponse);

      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> updateEquip(
      String idEquip,
      String idBrand,
      String idModel,
      String name,
      String status,
      String year,
      String series,
      String hour,
      String tag,
      String owner) async {
    try {
      final body = {
        "id_equipamento": idEquip,
        "id_marca": idBrand,
        "id_modelo": idModel,
        "nome": name,
        "ano": year,
        "serie": series,
        "horimetro": hour,
        "proprietario": owner,
        "placa": tag,
        "status": status,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.UPDATE_EQUIPMENT, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Equipment.fromJson(parsedResponse);

      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listBrands() async {
    try {
      final body = {
        "id_user": await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_BRANDS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Brand.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listModels(String idBrand) async {
    try {
      final body = {
        "id_marca": idBrand,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_MODELS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Model.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  void initState() {
    validator = Validator(context: context);

    if (widget.id != null) {
      nameController.text = widget.name!;
      yearController.text = widget.year!;
      seriesController.text = widget.series!;
      scheduleController.text = widget.schedule!;
      ownerController.text = widget.owner!;
      tagController.text = widget.tag!;

      currentSelectedValueCategory = widget.brand!;
      currentSelectedValueSubcategory = widget.model!;

      _idCategory = widget.id_brand;
      _idSubcategory = widget.id_model;
    }

    super.initState();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController seriesController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    seriesController.dispose();
    scheduleController.dispose();
    ownerController.dispose();
    tagController.dispose();
    super.dispose();
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
                    widget.id != null
                        ? "Editar equipamento"
                        : "Adicionar equipamento",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                Text(
                  "Marca",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Dimens.textSize5,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: Dimens.minMarginApplication),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: listBrands(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final responseItem = Brand.fromJson(snapshot.data![0]);

                      if (responseItem.rows != 0) {
                        var categoryList = <String>[];

                        categoryList.add("Selecione");
                        for (var i = 0; i < snapshot.data!.length; i++) {
                          categoryList
                              .add(Brand.fromJson(snapshot.data![i]).nome);
                        }

                        print("aaaaaaaaaaaaa" + categoryList.toString());

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
                                    currentSelectedValueSubcategory =
                                        "Selecione";
                                    currentSelectedValueCategory = newValue!;

                                    if (categoryList.indexOf(newValue) > 0) {
                                      _categoryPosition =
                                          categoryList.indexOf(newValue) - 1;
                                      _idCategory = Brand.fromJson(snapshot
                                              .data![_categoryPosition!])
                                          .id
                                          .toString();
                                      _idSubcategory = null;
                                    } else {
                                      _idCategory = null;
                                    }

                                    print(currentSelectedValueCategory +
                                        _categoryPosition.toString() +
                                        _idCategory.toString());
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
                      } else {}
                    } else if (snapshot.hasError) {
                      return Styles().defaultErrorRequest;
                    }
                    return Styles().defaultLoading;
                  },
                ),
                SizedBox(height: Dimens.minMarginApplication),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: listModels(_idCategory.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final responseItem = Model.fromJson(snapshot.data![0]);

                      if (responseItem.rows != 0) {
                        var subCategoryList = <String>[];

                        subCategoryList.add("Selecione");
                        for (var i = 0; i < snapshot.data!.length; i++) {
                          subCategoryList
                              .add(Model.fromJson(snapshot.data![i]).nome);
                        }

                        print("aaaaaaaaaaaaa" + subCategoryList.toString());

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Modelo",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: Dimens.textSize5,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: Dimens.minMarginApplication),
                              InputDecorator(
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
                                      value: currentSelectedValueSubcategory,
                                      isDense: true,
                                      onChanged: (newValue) {
                                        setState(() {
                                          currentSelectedValueSubcategory =
                                              newValue!;
                                          _subcategoryPosition = subCategoryList
                                                  .indexOf(newValue) -
                                              1;

                                          if (subCategoryList
                                                  .indexOf(newValue) >
                                              0) {
                                            _subcategoryPosition =
                                                subCategoryList
                                                        .indexOf(newValue) -
                                                    1;
                                            _idSubcategory = Model.fromJson(
                                                    snapshot.data![
                                                        _subcategoryPosition!])
                                                .id
                                                .toString();
                                          } else {
                                            _idSubcategory = null;
                                          }

                                          print(
                                              currentSelectedValueSubcategory +
                                                  _subcategoryPosition
                                                      .toString() +
                                                  _idSubcategory.toString());
                                        });
                                      },
                                      items:
                                          subCategoryList.map((String value) {
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
                                  )))
                            ]);
                      } else {}
                    } else if (snapshot.hasError) {
                      return Styles().defaultErrorRequest;
                    }
                    return Center(/*child: CircularProgressIndicator()*/);
                  },
                ),
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Nome do equipamento',
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
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: seriesController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Série',
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
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Ano',
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
                  controller: ownerController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Proprietário',
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
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Placa',
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
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: scheduleController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Horímetro',
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
                Container(
                  margin: EdgeInsets.only(top: Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Styles().styleDefaultButton,
                    onPressed: () async {
                /*      if (!validator.validateGenericTextField(
                          nameController.text, "Nome")) return;
                      if (!validator.validateGenericTextField(
                          seriesController.text, "Série")) return;
                      if (!validator.validateGenericTextField(
                          yearController.text, "Ano")) return;
                      if (!validator.validateGenericTextField(
                          ownerController.text, "Proprietário")) return;
                      if (!validator.validateGenericTextField(
                          tagController.text, "Placa")) return;*/
                      // if (!validator.validateGenericTextField(
                      //     tagController.text, "TAG")) return;
                      //horimetro

                      setState(() {
                        _isLoading = true;
                      });

                      if (widget.id != null) {
                        await updateEquip(
                            widget.id.toString(),
                            _idCategory.toString(),
                            _idSubcategory.toString(),
                            nameController.text.toString(),
                            "1",
                            yearController.text.toString(),
                            seriesController.text.toString(),
                            scheduleController.text.toString(),
                            tagController.text.toString(),
                            ownerController.text.toString());
                      } else {
                        await saveEquip(
                            _idCategory.toString(),
                            _idSubcategory.toString(),
                            nameController.text.toString(),
                            "1",
                            yearController.text.toString(),
                            seriesController.text.toString(),
                            scheduleController.text.toString(),
                            tagController.text.toString(),
                            ownerController.text.toString());
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
