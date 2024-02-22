import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/application_messages.dart';
import '../../config/masks.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/brand.dart';
import '../../model/employee.dart';
import '../../model/fleet.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';
import 'alert_dialog_pick_files.dart';

class FleetFormAlertDialog extends StatefulWidget {
  final String? id;
  final String? name;
  final String? obs;
  final String? status;
  final String? url;

  FleetFormAlertDialog(
      {Key? key, this.id, this.name, this.obs, this.status, this.url});

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<FleetFormAlertDialog> createState() => _FleetFormAlertDialog();
}

class _FleetFormAlertDialog extends State<FleetFormAlertDialog> {
  late Validator validator;
  bool _isLoading = false;

  bool light = false;

  File _imagePicked = File("");

  final postRequest = PostRequest();

  Future<void> saveFleet(File image, String name, String obs) async {
    try {
      final json = await postRequest.sendPostRequestMultiPartFleet(
          Links.SAVE_FLEET,
          image,
          await Preferences.getUserData()!.id.toString(),
          name,
          obs);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Fleet.fromJson(_map[0]);

      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> updateFleet(File image, String idFleet, String name, String obs, String status) async {
    try {
      final json = await postRequest.sendPostRequestMultiPartUpdateFleet(
          Links.UPDATE_FLEET,
          image,
          idFleet,
          name,
          obs,
          status);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Fleet.fromJson(_map[0]);

      if (response.status == "01") {
        Navigator.of(context).pop(true);
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  void initState() {
    validator = Validator(context: context);

    if (widget.id != null) {
      nameController.text = widget.name!;
      obsController.text = widget.obs!;

      if (widget.status == "1") {
        light = true;
      } else {
        light = false;
      }
    }

    super.initState();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController obsController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    obsController.dispose();
    super.dispose();
  }

  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() {
        _imagePicked = imageTemp;
      });

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() {
        _imagePicked = imageTemp;
      });

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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
                    widget.id != null ? "Editar Frota" : "Adicionar Frota",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Dimens.textSize6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                SizedBox(height: Dimens.marginApplication),
                TextField(
                  controller: obsController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: OwnerColors.colorPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Observação',
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
                Styles().div_horizontal,
                Visibility(
                    visible: widget.id != null,
                    child: Row(
                      children: [
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
                      ],
                    )),
                SizedBox(height: Dimens.marginApplication),
                Text(
                  widget.id != null ? "Editar Imagem" : "Adicionar Imagem",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Dimens.textSize5,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                Container(
                    height: 40,
                    child: ElevatedButton(
                        style: Styles().styleAlternativeButton,
                        onPressed: () {
                          showModalBottomSheet<dynamic>(
                              isScrollControlled: true,
                              context: context,
                              shape: Styles().styleShapeBottomSheet,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return PickFilesAlertDialog(
                                    iconCamera: IconButton(
                                        onPressed: () {
                                          pickImageCamera();
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.camera_alt,
                                            color: Colors.black),
                                        iconSize: 60),
                                    iconGallery: IconButton(
                                        onPressed: () {
                                          pickImageGallery();
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.photo,
                                            color: Colors.black),
                                        iconSize: 60));
                              });
                        },
                        child: Text(
                          "Escolher Arquivo",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Dimens.textSize4,
                              color: Colors.white),
                        ))),
                SizedBox(height: Dimens.marginApplication),
                Visibility(
                  visible: _imagePicked.path != "",
                  child: Image.file(
                    _imagePicked,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ),
                ),
                SizedBox(height: Dimens.marginApplication),
                Container(
                  margin: EdgeInsets.only(top: Dimens.marginApplication),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Styles().styleDefaultButton,
                    onPressed: () async {
                /*      if (!validator.validateGenericTextField(
                          nameController.text, "Nome")) return;
                      if (!validator.validateGenericTextField(
                          obsController.text, "Observação")) return;
*/
                      setState(() {
                        _isLoading = true;
                      });

                      if (widget.id != null) {

                        await updateFleet(
                          _imagePicked,
                            widget.id!,
                            nameController.text.toString(),
                            obsController.text.toString(),
                            light ? "1" : "2");
                      } else {
                        if (_imagePicked.path == "") {
                          ApplicationMessages(context: context).showMessage("É necessário adicionar uma imagem.");

                        } else {
                          await saveFleet(
                              _imagePicked,
                              nameController.text.toString(),
                              obsController.text.toString());
                        }

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
