import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:icontrol/model/task/task_comment.dart';
import 'package:icontrol/res/styles.dart';
import 'package:icontrol/ui/components/alert_dialog_add_checklist.dart';
import 'package:icontrol/ui/components/alert_dialog_change_name_task.dart';
import 'package:icontrol/ui/components/alert_dialog_edit_comment.dart';
import 'package:icontrol/ui/components/alert_dialog_select_employee.dart';
import 'package:icontrol/ui/components/alert_dialog_select_status.dart';
import 'package:icontrol/ui/components/alert_dialog_update_task_item.dart';
import 'package:icontrol/ui/components/alert_zoom_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rich_editor/rich_editor.dart';

import '../../../../config/application_messages.dart';
import '../../../../config/preferences.dart';
import '../../../../global/application_constant.dart';
import '../../../../model/photo.dart';
import '../../../../res/dimens.dart';
import '../../../../res/owner_colors.dart';
import '../../../../res/strings.dart';
import '../../../../web_service/links.dart';
import '../../../../web_service/service_response.dart';
import '../../../config/useful.dart';
import '../../../config/validator.dart';
import '../../../model/equipment.dart';
import '../../../model/task/task.dart';
import '../../../model/task/task_attachment.dart';
import '../../../model/task/task_checklist.dart';
import '../../../model/task/task_employee.dart';
import '../../components/alert_dialog_generic.dart';
import '../../components/alert_dialog_pick_files.dart';
import '../../components/custom_app_bar.dart';
import '../home.dart';

class TaskDetail extends StatefulWidget {
  const TaskDetail({Key? key}) : super(key: key);

  @override
  State<TaskDetail> createState() => _TaskDetail();
}

enum SampleItemTask { itemEdit, itemDelete }

class _TaskDetail extends State<TaskDetail> {
  late Validator validator;
  bool _isLoading = false;

  late int _id;
  late int _idFleet;

  String currentSelectedValueCategory = "Selecione";

  int? _categoryPosition;

  String? _idCategory;

  final TextEditingController commentController = TextEditingController();
  final TextEditingController commentEditController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final postRequest = PostRequest();

  @override
  void initState() {
    validator = Validator(context: context);
    commentController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    commentEditController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _downloadFile(String url) async {
    try {
      /// Verify we have storage permissions first.
      /// Code snippet showing me calling my devicePermissions service provider
      /// to request "storage" permission on Android.
      // await devicePermissions
      //     .storagePermissions()
      //     .then((granted) async {
      //   /// Get short lived url from google cloud storage for non-public file
      //   final String? shortLivedUrl...
      //
      //   if (shortLivedUrl == null) {
      //   throw Exception('Could not generate a '
      //   'downloadable url. Please try again.');
      //   }
      //
      //   final String url = shortLivedUrl;
      print(url);

      /// Get just the filename from the short lived (super long) url
      final String filename = Uri.parse(url).path.split("/").last;
      print('filename: $filename');

      Directory? directory;

      if (Platform.isIOS) {
        directory = await getDownloadsDirectory();
        print(directory?.path);
      } else if (Platform.isAndroid) {
        /// For Android get the application's scoped cache directory
        /// path.
        directory = await getTemporaryDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access local storage for '
            'download. Please try again.');
      }

      print('Temp cache save path: ${directory.path}/$filename');

      /// Use Dio package to download the short lived url to application cache
      await Dio().download(
        url,
        '${directory.path}/$filename',
        // onReceiveProgress: _showDownloadProgress,
      );

      /// For Android call the flutter_file_dialog package, which will give
      /// the option to save the now downloaded file by Dio (to temp
      /// application cache) to wherever the user wants including Downloads!
      if (Platform.isAndroid) {
        final params =
            SaveFileDialogParams(sourceFilePath: '${directory.path}/$filename');
        final filePath = await FlutterFileDialog.saveFile(params: params);

        print('Download path: $filePath');
      }

      /* on DevicePermissionException catch (e) {
      print(e);
      await OverlayMessage.showAlertDialog(
        context,
        title: 'Need Storage Permission',
        message: devicePermissions.errorMessage,
        barrierDismissible: true,
        leftAction: (context, controller, setState) {
          return TextButton(
            child: Text('Cancel'),
            onPressed: () async {
              controller.dismiss();
            },
          );
        },
        rightAction: (context, controller, setState) {
          return TextButton(
            child: Text('Open App Settings'),
            onPressed: () async {
              controller.dismiss();
              Future.delayed(Duration.zero, () async {
                /// Using permission_handler package we can easily give
                /// the user the option to tap and open settings from the
                /// app and manually allow storage.
                await devicePermissions.openManualAppSettings();
              });
            },
          );
        },
      );
   */
    } catch (e) {
      print(e.toString());
    }
  }

  Future pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'mp4', 'mkv'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);

        final imageTemp = File(file.path!);
        sendAttachment(imageTemp, "2", _id.toString());
      }
    } on PlatformException catch (e) {
      print('Failed to pick file: $e');
    }
  }

  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);

      sendAttachment(imageTemp, "1", _id.toString());
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);

      sendAttachment(imageTemp, "1", _id.toString());
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<Map<String, dynamic>> updateChecklistName(
      String idChecklist, String name) async {
    try {
      final body = {
        "id_checklist": idChecklist,
        "nome": name,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.UPDATE_TASK_CHECKLIST, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskChecklist.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteTask(String idTask) async {
    try {
      final body = {"id_tarefa": idTask, "token": ApplicationConstant.TOKEN};

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.DELETE_TASK, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      if (response.status == "01") {
        Navigator.of(context).pop();
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> sendAttachment(
      File image, String typeDocument, String idTask) async {
    try {
      final json = await postRequest.sendPostRequestMultiPartAttachment(
          Links.SAVE_ATTACHMENT,
          image,
          await Preferences.getUserData()!.id.toString(),
          idTask,
          typeDocument);

      List<Map<String, dynamic>> _map = [];
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskAttachment.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listAttachments(String idTask) async {
    try {
      final body = {
        "tarefa_id": idTask,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_ATTACHMENTS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = TaskChecklist.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteAttachment(String idAttachment) async {
    try {
      final body = {
        "id_anexo": idAttachment,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DELETE_ATTACHMENT, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskChecklist.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> saveChecklistItem(String idCheckList,
      String name, String hourMeter, String forecast) async {
    try {
      final body = {
        "id_checklist": idCheckList,
        "nome": name,
        "previsao": forecast,
        /* "10/10/2023 23:00"*/
        "horimetro": hourMeter,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(
          Links.SAVE_TASK_CHECKLIST_ITEMS, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> checkUncheckItem(String idChecklistItem) async {
    try {
      final body = {
        "id_checklist_item": idChecklistItem,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.CHECK_UNCHECK_ITEM, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskChecklist.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteChecklistItem(
      String idChecklistItem) async {
    try {
      final body = {
        "id_checklist_item": idChecklistItem,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(
          Links.DELETE_TASK_CHECKLIST_ITEM, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteChecklist(String idChecklist) async {
    try {
      final body = {
        "id_checklist": idChecklist,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DELETE_TASK_CHECKLIST, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listChecklists(String idTask) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_TASK_CHECKLISTS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = TaskChecklist.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listChecklistItems(
      String idChecklist) async {
    try {
      final body = {
        "id_checklist": idChecklist,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(
          Links.LIST_TASK_CHECKLIST_ITEMS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = TaskChecklist.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listTaskEmployees(String idTask) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_TASK_EMPLOYEE, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = TaskEmployee.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteTaskEmployee(
      String idTask, String idEmployee) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_funcionario": idEmployee,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DELETE_TASK_EMPLOYEE, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = TaskEmployee.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> saveComment(String idTask, String desc) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_usuario": await Preferences.getUserData()!.id,
        "descricao": desc,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.SAVE_TASK_COMMENT, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      commentController.text = "";

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> updateComment(
      String idComment, String desc) async {
    try {
      final body = {
        "id_comentario": idComment,
        "id_usuario": await Preferences.getUserData()!.id,
        "descricao": desc,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.UPDATE_TASK_COMMENT, body);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      commentEditController.text = "";

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listComments(String idTask) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.LIST_TASK_COMMENTS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Task.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> deleteComment(String idComment) async {
    try {
      final body = {
        "id_comentario": idComment,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.DELETE_TASK_COMMENT, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      if (response.status == "01") {
        setState(() {});
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listEquips() async {
    try {
      final body = {
        "id_user": Preferences.getUserData()!.tipo == 1
            ? Preferences.getUserData()!.id.toString()
            : Preferences.getUserData()!.id_empresa.toString(),
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

  Future<List<Map<String, dynamic>>> listTaskId(String idTask) async {
    try {
      final body = {
        "tarefa_id": idTask,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_ID_TASK, body);

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
      String? status,
      String? dateIn,
      String? dateOut}) async {
    try {
      var bd;

      if (desc != null) {
        bd = {
          "id_tarefa": idTask,
          "id_frota": idFleet,
          "descricao": desc,
          "token": ApplicationConstant.TOKEN,
        };
      } else if (idEquip != null) {
        bd = {
          "id_tarefa": idTask,
          "id_frota": idFleet,
          "id_equipamento": idEquip,
          "token": ApplicationConstant.TOKEN,
        };
      } else if (dateIn != null) {
        bd = {
          "id_tarefa": idTask,
          "id_frota": idFleet,
          "data_in": dateIn,
          "token": ApplicationConstant.TOKEN,
        };
      } else {
        bd = {
          "id_tarefa": idTask,
          "id_frota": idFleet,
          "data_out": dateOut,
          "token": ApplicationConstant.TOKEN,
        };
      }
      // final body = {
      //   "id_tarefa": idTask,
      //   "id_frota": idFleet,
      //   "id_equipamento": idEquip,
      //   "nome": name,
      //   "descricao": desc,
      //   "checklist": checklist,
      //   "status": status,
      //   "token": ApplicationConstant.TOKEN,
      // };

      print('HTTP_BODY: $bd');

      final json = await postRequest.sendPostRequest(Links.UPDATE_TASK, bd);

      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  GlobalKey<RichEditorState> keyEditor = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Map data = {};
    data = ModalRoute.of(context)!.settings.arguments as Map;

    _id = data['id'];
    _idFleet = data['id_fleet'];

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return OwnerColors.colorPrimary;
      }
      return OwnerColors.colorPrimary;
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          title: "Detalhes da tarefa",
          isVisibleBackButton: true, /*isVisibleFavoriteButton: true*/
        ),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: listTaskId(_id.toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final response = Task.fromJson(snapshot.data![0]);

                  var color = response.cor_status.replaceAll("#", "");

                  var colorDate = response.cor_entrega.replaceAll("#", "");

                  descController.text =
                      Useful().removeAllHtmlTags(response.descricao);

                  currentSelectedValueCategory = response.nome_equipamento;

                  _idCategory = response.id_equipamento.toString();

                  return Stack(children: [
                    SingleChildScrollView(
                        child: Container(
                      padding: EdgeInsets.only(bottom: 200),
                      child: Column(
                        children: [
                          // SizedBox(height: Dimens.minMarginApplication),
                          Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image.asset(
                              //   'images/random.jpg',
                              //   height: 190,
                              //   width: double.infinity,
                              //   fit: BoxFit.fitWidth,
                              // ),
                              Container(
                                  margin:
                                      EdgeInsets.all(Dimens.marginApplication),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
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
                                                          builder: (BuildContext
                                                              context) {
                                                            return ChangeNameTaskAlertDialog(
                                                              id: _id
                                                                  .toString(),
                                                              idFleet: _idFleet
                                                                  .toString(),
                                                              name:
                                                                  response.nome,
                                                            );
                                                          });
                                                  if (result == true) {
                                                    setState(() {});
                                                  }
                                                },
                                                child: Text(
                                                  response.nome,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: Dimens.textSize6,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                            // SizedBox(
                                            //     height:
                                            //         Dimens.minMarginApplication),
                                            // Text(
                                            //   Strings.littleLoremIpsum,
                                            //   style: TextStyle(
                                            //     fontStyle: FontStyle.italic,
                                            //     fontFamily: 'Inter',
                                            //     fontSize: Dimens.textSize4,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            Container(
                                                height: 40,
                                                child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      padding: MaterialStateProperty.all<
                                                              EdgeInsets>(
                                                          EdgeInsets.all(Dimens
                                                              .buttonPaddingApplication)),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.white),
                                                    ),
                                                    onPressed: () {
                                                      showModalBottomSheet<
                                                          dynamic>(
                                                        isScrollControlled:
                                                            true,
                                                        context: context,
                                                        shape: Styles()
                                                            .styleShapeBottomSheet,
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        builder: (BuildContext
                                                            context) {
                                                          return GenericAlertDialog(
                                                              title: Strings
                                                                  .attention,
                                                              content:
                                                                  "Tem certeza que deseja deletar esta tarefa?",
                                                              btnBack:
                                                                  TextButton(
                                                                      child:
                                                                          Text(
                                                                        Strings
                                                                            .no,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          color:
                                                                              Colors.black54,
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }),
                                                              btnConfirm:
                                                                  TextButton(
                                                                      child: Text(
                                                                          Strings
                                                                              .yes),
                                                                      onPressed:
                                                                          () {
                                                                        deleteTask(
                                                                            _id.toString());
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }));
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      "Deletar tarefa",
                                                      style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize:
                                                              Dimens.textSize4,
                                                          color: Colors.red),
                                                    ))),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.description_outlined,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Descrição: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Container(
                                            height: 280,
                                            child:
                                                // Insert widget into tree
                                                RichEditor(
                                              key: keyEditor,
                                              value: response.descricao,
                                              editorOptions: RichEditorOptions(
                                                placeholder: 'Descrição...',
                                                // backgroundColor: Colors.blueGrey, // Editor's bg color
                                                // baseTextColor: Colors.white,
                                                // editor padding
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                // font name
                                                baseFontFamily: 'sans-serif',
                                                // Position of the editing bar (BarPosition.TOP or BarPosition.BOTTOM)
                                                barPosition: BarPosition.TOP,
                                              ),
                                              // You can return a Link (maybe you need to upload the image to your
                                              // storage before displaying in the editor or you can also use base64
                                            )),
                                        Container(
                                            height: 40,
                                            child: ElevatedButton(
                                                style: Styles()
                                                    .styleAlternativeButton,
                                                onPressed: () async {
                                                  String? html = await keyEditor
                                                      .currentState
                                                      ?.getHtml();

                                                  updateTask(
                                                      idTask: _id.toString(),
                                                      idFleet:
                                                          _idFleet.toString(),
                                                      desc: html);
                                                },
                                                child: Text(
                                                  "Salvar descrição",
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize:
                                                          Dimens.textSize4,
                                                      color: Colors.white),
                                                ))),
                                        // SizedBox(
                                        //     height: 100.0,
                                        //     child: TextField(
                                        //       expands: true,
                                        //       minLines: null,
                                        //       maxLines: null,
                                        //       controller: descController,
                                        //       decoration: InputDecoration(
                                        //         focusedBorder:
                                        //             OutlineInputBorder(
                                        //           borderSide: BorderSide(
                                        //               color: OwnerColors
                                        //                   .colorPrimary,
                                        //               width: 1.5),
                                        //         ),
                                        //         enabledBorder:
                                        //             OutlineInputBorder(
                                        //           borderSide: BorderSide(
                                        //               color: Colors.grey,
                                        //               width: 1.0),
                                        //         ),
                                        //         hintText: 'Descrição...',
                                        //         hintStyle: TextStyle(
                                        //             color: Colors.grey),
                                        //         border: OutlineInputBorder(
                                        //           borderRadius: BorderRadius
                                        //               .circular(Dimens
                                        //                   .radiusApplication),
                                        //           borderSide: BorderSide.none,
                                        //         ),
                                        //         filled: true,
                                        //         fillColor: Colors.white,
                                        //         contentPadding: EdgeInsets.all(
                                        //             Dimens
                                        //                 .textFieldPaddingApplication),
                                        //       ),
                                        //       keyboardType: TextInputType.text,
                                        //       style: TextStyle(
                                        //         color: Colors.grey,
                                        //         fontSize: Dimens.textSize5,
                                        //       ),
                                        //       onChanged: (value) {
                                        //         updateTask(
                                        //             idTask: _id.toString(),
                                        //             idFleet:
                                        //                 _idFleet.toString(),
                                        //             desc: value.toString());
                                        //       },
                                        //     )),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.aspect_ratio,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Equipamento: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        FutureBuilder<
                                            List<Map<String, dynamic>>>(
                                          future: listEquips(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final responseItem =
                                                  Equipment.fromJson(
                                                      snapshot.data![0]);

                                              if (responseItem.rows != 0) {
                                                var categoryList = <String>[];

                                                categoryList.add("Selecione");
                                                for (var i = 0;
                                                    i < snapshot.data!.length;
                                                    i++) {
                                                  categoryList.add(
                                                      Equipment.fromJson(
                                                              snapshot.data![i])
                                                          .nome);
                                                }

                                                return InputDecorator(
                                                    decoration: const InputDecoration(
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width:
                                                                        1.0))),
                                                    child: Container(
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          String>(
                                                        isExpanded: true,
                                                        hint: Text(
                                                          "Selecione",
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            color: OwnerColors
                                                                .colorPrimary,
                                                          ),
                                                        ),
                                                        value:
                                                            currentSelectedValueCategory,
                                                        isDense: true,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            currentSelectedValueCategory =
                                                                newValue!;

                                                            if (categoryList
                                                                    .indexOf(
                                                                        newValue) >
                                                                0) {
                                                              _categoryPosition =
                                                                  categoryList.indexOf(
                                                                          newValue) -
                                                                      1;
                                                              _idCategory = Equipment
                                                                      .fromJson(
                                                                          snapshot
                                                                              .data![_categoryPosition!])
                                                                  .id
                                                                  .toString();

                                                              updateTask(
                                                                  idTask: _id
                                                                      .toString(),
                                                                  idFleet: _idFleet
                                                                      .toString(),
                                                                  idEquip:
                                                                      _idCategory);
                                                            } else {
                                                              _idCategory =
                                                                  null;
                                                            }

                                                            print(currentSelectedValueCategory +
                                                                _categoryPosition
                                                                    .toString() +
                                                                _idCategory
                                                                    .toString());
                                                          });
                                                        },
                                                        items: categoryList.map(
                                                            (String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: OwnerColors
                                                                      .colorPrimary,
                                                                )),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    )));
                                              } else {}
                                            } else if (snapshot.hasError) {
                                              return Styles()
                                                  .defaultErrorRequest;
                                            }
                                            return Styles().defaultLoading;
                                          },
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.calendar_month,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Previsão de entrega: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
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
                                                    dateFormat:
                                                        'dd MMMM yyyy HH:mm',
                                                    initialDateTime:
                                                        DateTime.now(),
                                                    minDateTime: DateTime(2000),
                                                    maxDateTime: DateTime(3000),
                                                    onMonthChangeStartWithFirstDate:
                                                        true,
                                                    onConfirm: (dateTime,
                                                        List<int> index) {
                                                      DateTime selectdate =
                                                          dateTime;
                                                      final selIOS = DateFormat(
                                                              'dd/MM/yyyy HH:mm')
                                                          .format(selectdate);
                                                      print(selIOS);

                                                      updateTask(
                                                          idTask:
                                                              _id.toString(),
                                                          idFleet: _idFleet
                                                              .toString(),
                                                          dateIn: selIOS);
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  "Data de início",
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize:
                                                          Dimens.textSize4,
                                                      color: Colors.white),
                                                ))),
                                        SizedBox(
                                            height:
                                                Dimens.minMarginApplication),
                                        Card(
                                            color: OwnerColors.darkGrey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(Dimens
                                                      .minRadiusApplication),
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
                                                      response.data_in +
                                                          " - " +
                                                          response.data_in_hora,
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize:
                                                            Dimens.textSize4,
                                                        color: Colors.white,
                                                      ),
                                                    ))
                                              ],
                                            )),
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
                                                    dateFormat:
                                                        'dd MMMM yyyy HH:mm',
                                                    initialDateTime:
                                                        DateTime.now(),
                                                    minDateTime: DateTime(2000),
                                                    maxDateTime: DateTime(3000),
                                                    onMonthChangeStartWithFirstDate:
                                                        true,
                                                    onConfirm: (dateTime,
                                                        List<int> index) {
                                                      DateTime selectdate =
                                                          dateTime;
                                                      final selIOS = DateFormat(
                                                              'dd/MM/yyyy HH:mm')
                                                          .format(selectdate);
                                                      print(selIOS);

                                                      updateTask(
                                                          idTask:
                                                              _id.toString(),
                                                          idFleet: _idFleet
                                                              .toString(),
                                                          dateOut: selIOS);
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
                                            height:
                                                Dimens.minMarginApplication),
                                        Card(
                                            color: Color(
                                                int.parse("0xFF$colorDate")),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(Dimens
                                                      .minRadiusApplication),
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
                                                      response.data_out !=
                                                                  null &&
                                                              response.data_out_hora !=
                                                                  null
                                                          ? response.data_out +
                                                              " - " +
                                                              response
                                                                  .data_out_hora +
                                                              " "
                                                          : "00/00/0000 00:00 ",
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize:
                                                            Dimens.textSize4,
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                                Text(
                                                  response.msg_entrega
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize:
                                                          Dimens.textSize5,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 7),
                                              ],
                                            )),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.label_important_outline,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Status: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height:
                                                Dimens.minMarginApplication),
                                        Align(
                                            alignment:
                                                AlignmentDirectional.topStart,
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
                                                          builder: (BuildContext
                                                              context) {
                                                            return SelectStatusAlertDialog(
                                                                id: _id
                                                                    .toString(),
                                                                idFleet: _idFleet
                                                                    .toString());
                                                          });
                                                  if (result == true) {
                                                    setState(() {});
                                                  }
                                                },
                                                child: Card(
                                                    color: Color(int.parse(
                                                        "0xFF$color")),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(Dimens
                                                              .minRadiusApplication),
                                                    ),
                                                    child: Container(
                                                        padding: EdgeInsets.all(
                                                            Dimens
                                                                .minPaddingApplication),
                                                        child: Text(
                                                          response.nome_status,
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: Dimens
                                                                .textSize5,
                                                            color: Colors.white,
                                                          ),
                                                        ))))),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.people_alt_outlined,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Funcionários: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Container(
                                            height: 40,
                                            child: ElevatedButton(
                                                style: Styles()
                                                    .styleAlternativeButton,
                                                onPressed: () async {
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
                                                          builder: (BuildContext
                                                              context) {
                                                            return SelectEmployeeAlertDialog(
                                                                id: response.id
                                                                    .toString());
                                                          });
                                                  if (result == true) {
                                                    setState(() {});
                                                  }
                                                },
                                                child: Text(
                                                  "Adicionar funcionário",
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize:
                                                          Dimens.textSize4,
                                                      color: Colors.white),
                                                ))),
                                        FutureBuilder<
                                            List<Map<String, dynamic>>>(
                                          future:
                                              listTaskEmployees(_id.toString()),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final responseItem =
                                                  TaskEmployee.fromJson(
                                                      snapshot.data![0]);

                                              if (responseItem.rows != 0) {
                                                return ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final response =
                                                        TaskEmployee.fromJson(
                                                            snapshot
                                                                .data![index]);

                                                    return InkWell(
                                                        onTap: () => {},
                                                        child: Card(
                                                          elevation: Dimens
                                                              .minElevationApplication,
                                                          color: Colors.white,
                                                          margin: EdgeInsets
                                                              .all(Dimens
                                                                  .minMarginApplication),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(Dimens
                                                                    .minRadiusApplication),
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .paddingApplication),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: Dimens
                                                                            .marginApplication),
                                                                    child: ClipOval(
                                                                        child: SizedBox.fromSize(
                                                                            size: Size.fromRadius(20),
                                                                            // Image radius
                                                                            child: Image.network(
                                                                              ApplicationConstant.URL_AVATAR + response.avatar.toString(),
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder: (context, exception, stackTrack) => Image.asset(
                                                                                'images/main_logo_1.png',
                                                                              ),
                                                                            )))),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        response
                                                                            .nome,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              Dimens.textSize5,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        AlignmentDirectional
                                                                            .topEnd,
                                                                    child: PopupMenuButton<
                                                                        SampleItemTask>(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .arrow_drop_down_sharp,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      onSelected:
                                                                          (SampleItemTask
                                                                              item) {
                                                                        if (item ==
                                                                            SampleItemTask.itemDelete) {
                                                                          showModalBottomSheet<
                                                                              dynamic>(
                                                                            isScrollControlled:
                                                                                true,
                                                                            context:
                                                                                context,
                                                                            shape:
                                                                                Styles().styleShapeBottomSheet,
                                                                            clipBehavior:
                                                                                Clip.antiAliasWithSaveLayer,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return GenericAlertDialog(
                                                                                  title: Strings.attention,
                                                                                  content: "Tem certeza que deseja remover este funcionário?",
                                                                                  btnBack: TextButton(
                                                                                      child: Text(
                                                                                        Strings.no,
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Inter',
                                                                                          color: Colors.black54,
                                                                                        ),
                                                                                      ),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      }),
                                                                                  btnConfirm: TextButton(
                                                                                      child: Text(Strings.yes),
                                                                                      onPressed: () {
                                                                                        deleteTaskEmployee(_id.toString(), response.id.toString());
                                                                                        Navigator.of(context).pop();
                                                                                      }));
                                                                            },
                                                                          );
                                                                        }
                                                                      },
                                                                      itemBuilder: (BuildContext
                                                                              context) =>
                                                                          <PopupMenuEntry<
                                                                              SampleItemTask>>[
                                                                        const PopupMenuItem<
                                                                            SampleItemTask>(
                                                                          value:
                                                                              SampleItemTask.itemDelete,
                                                                          child:
                                                                              Text('Deletar'),
                                                                        ),
                                                                      ],
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                );
                                              } else {
                                                return Container();
                                              }
                                            } else if (snapshot.hasError) {
                                              return Styles()
                                                  .defaultErrorRequest;
                                            }
                                            return Styles().defaultLoading;
                                          },
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.attach_file,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Anexos: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Container(
                                            height: 40,
                                            child: ElevatedButton(
                                                style: Styles()
                                                    .styleAlternativeButton,
                                                onPressed: () {
                                                  showModalBottomSheet<dynamic>(
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape: Styles()
                                                          .styleShapeBottomSheet,
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      builder: (BuildContext
                                                          context) {
                                                        return PickFilesAlertDialog(
                                                            iconCamera:
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      pickImageCamera();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    icon: Icon(
                                                                        Icons
                                                                            .camera_alt,
                                                                        color: Colors
                                                                            .black),
                                                                    iconSize:
                                                                        60),
                                                            iconGallery:
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      pickImageGallery();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    icon: Icon(
                                                                        Icons
                                                                            .photo,
                                                                        color: Colors
                                                                            .black),
                                                                    iconSize:
                                                                        60),
                                                            iconDocument:
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      pickDocument();

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    icon: Icon(
                                                                        Icons
                                                                            .file_copy_rounded,
                                                                        color: Colors
                                                                            .black),
                                                                    iconSize:
                                                                        60));
                                                      });
                                                },
                                                child: Text(
                                                  "Escolher Arquivo",
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize:
                                                          Dimens.textSize4,
                                                      color: Colors.white),
                                                ))),
                                        SizedBox(
                                          height: Dimens.marginApplication,
                                        ),
                                        FutureBuilder<
                                            List<Map<String, dynamic>>>(
                                          future:
                                              listAttachments(_id.toString()),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final responseItem =
                                                  TaskAttachment.fromJson(
                                                      snapshot.data![0]);

                                              if (responseItem.rows != 0) {
                                                return ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final response =
                                                        TaskAttachment.fromJson(
                                                            snapshot
                                                                .data![index]);

                                                    return InkWell(
                                                        onTap: () => {
                                                              if (response
                                                                      .tipo ==
                                                                  2)
                                                                {
                                                                  _downloadFile(ApplicationConstant
                                                                          .URL_ATTACHMENTS +
                                                                      response
                                                                          .url
                                                                          .toString())
                                                                }
                                                              else
                                                                {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return ZoomImageAlertDialog(
                                                                            content:
                                                                                ApplicationConstant.URL_ATTACHMENTS + response.url.toString());
                                                                      })
                                                                }
                                                            },
                                                        child: Card(
                                                          elevation: Dimens
                                                              .minElevationApplication,
                                                          color: Colors.white,
                                                          margin: EdgeInsets
                                                              .all(Dimens
                                                                  .minMarginApplication),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(Dimens
                                                                    .minRadiusApplication),
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .paddingApplication),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: Dimens
                                                                            .minMarginApplication),
                                                                    child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                                                                        child: Image.network(
                                                                          ApplicationConstant.URL_ATTACHMENTS +
                                                                              response.url.toString(),
                                                                          height:
                                                                              100,
                                                                          width:
                                                                              100,
                                                                          errorBuilder: (context, exception, stackTrack) =>
                                                                              Image.asset(
                                                                            'images/main_logo_1.png',
                                                                            height:
                                                                                100,
                                                                            width:
                                                                                100,
                                                                          ),
                                                                        ))),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        response.url +
                                                                            "\n\nAdicionado em: " +
                                                                            response.data_cadastro,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              Dimens.textSize5,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        AlignmentDirectional
                                                                            .topEnd,
                                                                    child: PopupMenuButton<
                                                                        SampleItemTask>(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .arrow_drop_down_sharp,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      onSelected:
                                                                          (SampleItemTask
                                                                              item) {
                                                                        if (item ==
                                                                            SampleItemTask.itemDelete) {
                                                                          showModalBottomSheet<
                                                                              dynamic>(
                                                                            isScrollControlled:
                                                                                true,
                                                                            context:
                                                                                context,
                                                                            shape:
                                                                                Styles().styleShapeBottomSheet,
                                                                            clipBehavior:
                                                                                Clip.antiAliasWithSaveLayer,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return GenericAlertDialog(
                                                                                  title: Strings.attention,
                                                                                  content: "Tem certeza que deseja remover este anexo?",
                                                                                  btnBack: TextButton(
                                                                                      child: Text(
                                                                                        Strings.no,
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Inter',
                                                                                          color: Colors.black54,
                                                                                        ),
                                                                                      ),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      }),
                                                                                  btnConfirm: TextButton(
                                                                                      child: Text(Strings.yes),
                                                                                      onPressed: () {
                                                                                        deleteAttachment(response.id.toString());
                                                                                        Navigator.of(context).pop();
                                                                                      }));
                                                                            },
                                                                          );
                                                                        }
                                                                      },
                                                                      itemBuilder: (BuildContext
                                                                              context) =>
                                                                          <PopupMenuEntry<
                                                                              SampleItemTask>>[
                                                                        const PopupMenuItem<
                                                                            SampleItemTask>(
                                                                          value:
                                                                              SampleItemTask.itemDelete,
                                                                          child:
                                                                              Text('Deletar'),
                                                                        ),
                                                                      ],
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                );
                                              } else {
                                                return Container();
                                              }
                                            } else if (snapshot.hasError) {
                                              return Styles()
                                                  .defaultErrorRequest;
                                            }
                                            return Styles().defaultLoading;
                                          },
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Visibility(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: Dimens
                                                            .minMarginApplication),
                                                    child: Icon(
                                                      Icons.checklist,
                                                      size: 24,
                                                    )),
                                                Text(
                                                  "Checklists: ",
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: Dimens.textSize5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    Dimens.marginApplication),
                                            Container(
                                                height: 40,
                                                child: ElevatedButton(
                                                    style: Styles()
                                                        .styleAlternativeButton,
                                                    onPressed: () async {
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
                                                                return AddChecklistAlertDialog(
                                                                  id: response
                                                                      .id
                                                                      .toString(),
                                                                );
                                                              });
                                                      if (result == true) {
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Text(
                                                      "Novo checklist",
                                                      style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize:
                                                              Dimens.textSize4,
                                                          color: Colors.white),
                                                    ))),
                                            SizedBox(
                                                height:
                                                    Dimens.marginApplication),
                                            FutureBuilder<
                                                List<Map<String, dynamic>>>(
                                              future: listChecklists(
                                                  _id.toString()),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  final responseItem =
                                                      TaskChecklist.fromJson(
                                                          snapshot.data![0]);

                                                  if (responseItem.rows != 0) {
                                                    return ListView.builder(
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          snapshot.data!.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final response =
                                                            TaskChecklist
                                                                .fromJson(snapshot
                                                                        .data![
                                                                    index]);

                                                        final TextEditingController
                                                            itemChecklistController =
                                                            TextEditingController();

                                                        final TextEditingController
                                                            hourMeterItemlistController =
                                                            TextEditingController();

                                                        final TextEditingController
                                                            forecastItemlistController =
                                                            TextEditingController();

                                                        final TextEditingController
                                                            editChecklistController =
                                                            TextEditingController();

                                                        editChecklistController
                                                                .text =
                                                            response.nome;

                                                        return InkWell(
                                                            onTap: () => {},
                                                            child: Card(
                                                              elevation: Dimens
                                                                  .minElevationApplication,
                                                              color:
                                                                  Colors.white,
                                                              margin: EdgeInsets
                                                                  .all(Dimens
                                                                      .minMarginApplication),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            Dimens.minRadiusApplication),
                                                              ),
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .all(Dimens
                                                                        .paddingApplication),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [

                                                                          Align(
                                                                              alignment:
                                                                              AlignmentDirectional
                                                                                  .topEnd,
                                                                              child: PopupMenuButton<
                                                                                  SampleItemTask>(
                                                                                icon:
                                                                                Icon(
                                                                                  Icons.arrow_drop_down_sharp,
                                                                                  color:
                                                                                  Colors.black,
                                                                                ),
                                                                                onSelected:
                                                                                    (SampleItemTask item) async {
                                                                                  if (item ==
                                                                                      SampleItemTask.itemEdit) {
                                                                                    final result = await showModalBottomSheet<dynamic>(
                                                                                        isScrollControlled: true,
                                                                                        context: context,
                                                                                        shape: Styles().styleShapeBottomSheet,
                                                                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                        builder: (BuildContext context) {
                                                                                          return AddChecklistAlertDialog(
                                                                                            id: response.id.toString(),
                                                                                            name: response.nome.toString(),
                                                                                          );
                                                                                        });
                                                                                    if (result == true) {
                                                                                      setState(() {});
                                                                                    }
                                                                                  } else {
                                                                                    showModalBottomSheet<dynamic>(
                                                                                      isScrollControlled: true,
                                                                                      context: context,
                                                                                      shape: Styles().styleShapeBottomSheet,
                                                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                      builder: (BuildContext context) {
                                                                                        return GenericAlertDialog(
                                                                                            title: Strings.attention,
                                                                                            content: "Tem certeza que deseja remover este checklist?",
                                                                                            btnBack: TextButton(
                                                                                                child: Text(
                                                                                                  Strings.no,
                                                                                                  style: TextStyle(
                                                                                                    fontFamily: 'Inter',
                                                                                                    color: Colors.black54,
                                                                                                  ),
                                                                                                ),
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                }),
                                                                                            btnConfirm: TextButton(
                                                                                                child: Text(Strings.yes),
                                                                                                onPressed: () {
                                                                                                  deleteChecklist(response.id.toString());
                                                                                                  Navigator.of(context).pop();
                                                                                                }));
                                                                                      },
                                                                                    );
                                                                                  }
                                                                                },
                                                                                itemBuilder: (BuildContext context) =>
                                                                                <PopupMenuEntry<SampleItemTask>>[
                                                                                  const PopupMenuItem<SampleItemTask>(
                                                                                    value: SampleItemTask.itemEdit,
                                                                                    child: Text('Editar'),
                                                                                  ),
                                                                                  const PopupMenuItem<SampleItemTask>(
                                                                                    value: SampleItemTask.itemDelete,
                                                                                    child: Text('Deletar'),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                          Container(
                                                                              margin: EdgeInsets.only(bottom: Dimens.minMarginApplication),
                                                                              child: TextField(
                                                                                controller: editChecklistController,
                                                                                onSubmitted: (value) async {
                                                                                  await updateChecklistName(response.id.toString(), value.toString());
                                                                                },
                                                                                decoration: InputDecoration(
                                                                                  hintText: 'Nome do checklist',
                                                                                  hintStyle: TextStyle(color: Colors.grey),
                                                                                  filled: false,
                                                                                  border: InputBorder.none,
                                                                                  fillColor: Colors.white,
                                                                                  contentPadding: EdgeInsets.all(Dimens.textFieldPaddingApplication),
                                                                                ),
                                                                                keyboardType: TextInputType.text,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Inter',
                                                                                  fontSize: Dimens.textSize6,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              )),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: Dimens.minPaddingApplication, bottom: Dimens.minPaddingApplication),
                                                                            child:
                                                                                LinearPercentIndicator(
                                                                              animation: true,
                                                                              lineHeight: 20.0,
                                                                              animationDuration: 300,
                                                                              percent: double.parse(response.perc_progresso) / 100,
                                                                              center: Text(response.perc_progresso.toString().split('.').first + "%"),
                                                                              barRadius: Radius.circular(20),
                                                                              progressColor: Colors.green,
                                                                            ),
                                                                          ),
                                                                          FutureBuilder<
                                                                              List<Map<String, dynamic>>>(
                                                                            future:
                                                                                listChecklistItems(response.id.toString()),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.hasData) {
                                                                                final responseItem = TaskChecklist.fromJson(snapshot.data![0]);

                                                                                if (responseItem.rows != 0) {
                                                                                  return ListView.builder(
                                                                                    primary: false,
                                                                                    shrinkWrap: true,
                                                                                    itemCount: snapshot.data!.length,
                                                                                    itemBuilder: (context, index) {
                                                                                      final response = TaskChecklist.fromJson(snapshot.data![index]);

                                                                                      bool isChecked = response.check == 1 ? true : false;

                                                                                      return InkWell(
                                                                                          onTap: () => {},
                                                                                          child: Container(
                                                                                            margin: EdgeInsets.only(top: Dimens.marginApplication),
                                                                                            color: Colors.grey[100],
                                                                                            child: Container(
                                                                                                padding: EdgeInsets.all(Dimens.minPaddingApplication),
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    Row(
                                                                                                      children: [
                                                                                                        // Container(
                                                                                                        //     margin: EdgeInsets.only(
                                                                                                        //         right: Dimens.minMarginApplication),
                                                                                                        //     child: ClipRRect(
                                                                                                        //         borderRadius: BorderRadius.circular(
                                                                                                        //             Dimens.minRadiusApplication),
                                                                                                        //         child: Image.network(
                                                                                                        //           ApplicationConstant.URL_AVATAR +
                                                                                                        //               response.url.toString(),
                                                                                                        //           height: 50,
                                                                                                        //           width: 50,
                                                                                                        //           errorBuilder: (context, exception,
                                                                                                        //               stackTrack) =>
                                                                                                        //               Image.asset(
                                                                                                        //                 'images/main_logo_1.png',
                                                                                                        //                 height: 50,
                                                                                                        //                 width: 50,
                                                                                                        //               ),
                                                                                                        //         ))),
                                                                                                        Checkbox(
                                                                                                          checkColor: Colors.white,
                                                                                                          fillColor: MaterialStateProperty.resolveWith(getColor),
                                                                                                          value: isChecked,
                                                                                                          onChanged: (bool? value) {
                                                                                                            checkUncheckItem(response.id.toString());
                                                                                                          },
                                                                                                        ),
                                                                                                        Expanded(
                                                                                                          child: Column(
                                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                            children: [
                                                                                                              Text(
                                                                                                                "Horimetro: " + response.horimetro + " | " + response.nome,
                                                                                                                style: TextStyle(
                                                                                                                  fontFamily: 'Inter',
                                                                                                                  fontSize: Dimens.textSize4,
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                  color: Colors.black,
                                                                                                                ),
                                                                                                              ),
                                                                                                              Visibility(
                                                                                                                  visible: response.previsao != null,
                                                                                                                  child: Column(children: [
                                                                                                                    // SizedBox(height: Dimens.minMarginApplication),
                                                                                                                    // Styles().div_horizontal,
                                                                                                                    // SizedBox(height: Dimens.minMarginApplication),
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
                                                                                                                              size: 12,
                                                                                                                            ),
                                                                                                                            SizedBox(width: 4),
                                                                                                                            Container(
                                                                                                                                padding: EdgeInsets.all(4),
                                                                                                                                child: Text(
                                                                                                                                  response.previsao.toString(),
                                                                                                                                  style: TextStyle(
                                                                                                                                    fontFamily: 'Inter',
                                                                                                                                    fontSize: Dimens.textSize3,
                                                                                                                                    color: Colors.white,
                                                                                                                                  ),
                                                                                                                                ))
                                                                                                                          ],
                                                                                                                        ))
                                                                                                                  ])),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        Align(
                                                                                                            alignment: AlignmentDirectional.topEnd,
                                                                                                            child: GestureDetector(
                                                                                                                onTap: () async {
                                                                                                                  final result = await showModalBottomSheet<dynamic>(
                                                                                                                    isScrollControlled: true,
                                                                                                                    context: context,
                                                                                                                    shape: Styles().styleShapeBottomSheet,
                                                                                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                                                    builder: (BuildContext context) {
                                                                                                                      return UpdateTaskItemAlertDialog(
                                                                                                                        id: response.id.toString(),
                                                                                                                        name: response.nome,
                                                                                                                        actualDate: response.previsao,
                                                                                                                        hourMeter: response.horimetro,
                                                                                                                      );
                                                                                                                    },
                                                                                                                  );
                                                                                                                  if (result == true) {
                                                                                                                    setState(() {});
                                                                                                                  }
                                                                                                                },
                                                                                                                child: Icon(
                                                                                                                  Icons.edit,
                                                                                                                  size: 16,
                                                                                                                ))),
                                                                                                        Align(
                                                                                                            alignment: AlignmentDirectional.topEnd,
                                                                                                            child: GestureDetector(
                                                                                                                onTap: () {
                                                                                                                  showModalBottomSheet<dynamic>(
                                                                                                                    isScrollControlled: true,
                                                                                                                    context: context,
                                                                                                                    shape: Styles().styleShapeBottomSheet,
                                                                                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                                                    builder: (BuildContext context) {
                                                                                                                      return GenericAlertDialog(
                                                                                                                          title: Strings.attention,
                                                                                                                          content: "Tem certeza que deseja remover este item?",
                                                                                                                          btnBack: TextButton(
                                                                                                                              child: Text(
                                                                                                                                Strings.no,
                                                                                                                                style: TextStyle(
                                                                                                                                  fontFamily: 'Inter',
                                                                                                                                  color: Colors.black54,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              onPressed: () {
                                                                                                                                Navigator.of(context).pop();
                                                                                                                              }),
                                                                                                                          btnConfirm: TextButton(
                                                                                                                              child: Text(Strings.yes),
                                                                                                                              onPressed: () {
                                                                                                                                deleteChecklistItem(response.id.toString());
                                                                                                                                Navigator.of(context).pop();
                                                                                                                              }));
                                                                                                                    },
                                                                                                                  );
                                                                                                                },
                                                                                                                child: Container(
                                                                                                                    margin: EdgeInsets.only(left: Dimens.marginApplication),
                                                                                                                    child: Icon(
                                                                                                                      Icons.close,
                                                                                                                      size: 16,
                                                                                                                    ))))
                                                                                                      ],
                                                                                                    ),
                                                                                                  ],
                                                                                                )),
                                                                                          ));
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
                                                                          SizedBox(
                                                                              height: Dimens.marginApplication),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                  child: TextField(
                                                                                controller: itemChecklistController,
                                                                                decoration: InputDecoration(
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: OwnerColors.colorPrimary, width: 1.5),
                                                                                  ),
                                                                                  enabledBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                                                                  ),
                                                                                  hintText: 'Nome',
                                                                                  hintStyle: TextStyle(color: Colors.grey),
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(Dimens.radiusApplication),
                                                                                    borderSide: BorderSide.none,
                                                                                  ),
                                                                                  filled: true,
                                                                                  fillColor: Colors.white,
                                                                                  contentPadding: EdgeInsets.all(4),
                                                                                ),
                                                                                keyboardType: TextInputType.text,
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontSize: Dimens.textSize5,
                                                                                ),
                                                                              )),
                                                                              SizedBox(width: 6,),
                                                                              Expanded(
                                                                                  child: TextField(
                                                                                controller: hourMeterItemlistController,
                                                                                decoration: InputDecoration(
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: OwnerColors.colorPrimary, width: 1.5),
                                                                                  ),
                                                                                  enabledBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                                                                  ),
                                                                                  hintText: 'Horímetro',
                                                                                  hintStyle: TextStyle(color: Colors.grey),
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(Dimens.radiusApplication),
                                                                                    borderSide: BorderSide.none,
                                                                                  ),
                                                                                  filled: true,
                                                                                  fillColor: Colors.white,
                                                                                  contentPadding: EdgeInsets.all(4),
                                                                                ),
                                                                                keyboardType: TextInputType.text,
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontSize: Dimens.textSize5,
                                                                                ),
                                                                              )),
                                                                              SizedBox(width: 6,),
                                                                              Expanded(
                                                                                  child: TextField(
                                                                                    onTap: () {
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

                                                                                          forecastItemlistController.text = selIOS;

                                                                                        },
                                                                                      );
                                                                                    },
                                                                                    readOnly: true,
                                                                                    controller: forecastItemlistController,
                                                                                    decoration: InputDecoration(
                                                                                      focusedBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(color: OwnerColors.colorPrimary, width: 1.5),
                                                                                      ),
                                                                                      enabledBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                                                                      ),
                                                                                      hintText: 'dd/mm/aaaa',
                                                                                      hintStyle: TextStyle(color: Colors.grey),
                                                                                      border: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius.circular(Dimens.radiusApplication),
                                                                                        borderSide: BorderSide.none,
                                                                                      ),
                                                                                      filled: true,
                                                                                      fillColor: Colors.white,
                                                                                      contentPadding: EdgeInsets.all(4),
                                                                                    ),
                                                                                    keyboardType: TextInputType.text,
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: Dimens.textSize5,
                                                                                    ),
                                                                                  )),

                                                                              IconButton(
                                                                                  onPressed: () {

                                                                   /*                 if (!validator.validateGenericTextField(
                                                                                        itemChecklistController.text, "Nome")) return;
                                                                                    if (!validator.validateGenericTextField(
                                                                                        hourMeterItemlistController.text, "Horimetro")) return;
                                                                                    if (!validator.validateGenericTextField(
                                                                                        forecastItemlistController.text, "Previsão")) return;

                                                                                   */ saveChecklistItem(
                                                                                      response.id.toString(),
                                                                                      itemChecklistController.text.toString(),
                                                                                      hourMeterItemlistController.text.toString(),
                                                                                      forecastItemlistController.text.toString()
                                                                                    );
                                                                                  },
                                                                                  icon: Icon(
                                                                                    Icons.check,
                                                                                    size: 24,
                                                                                  ))
                                                                            ],
                                                                          )
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
                                                    return Container();
                                                  }
                                                } else if (snapshot.hasError) {
                                                  return Styles()
                                                      .defaultErrorRequest;
                                                }
                                                return Styles().defaultLoading;
                                              },
                                            )
                                          ],
                                        )),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Styles().div_horizontal,
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: Dimens
                                                        .minMarginApplication),
                                                child: Icon(
                                                  Icons.comment_outlined,
                                                  size: 24,
                                                )),
                                            Text(
                                              "Comentários: ",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: Dimens.marginApplication),
                                        FutureBuilder<
                                            List<Map<String, dynamic>>>(
                                          future: listComments(_id.toString()),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final responseItem =
                                                  TaskComment.fromJson(
                                                      snapshot.data![0]);

                                              if (responseItem.rows != 0) {
                                                return ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final response =
                                                        TaskComment.fromJson(
                                                            snapshot
                                                                .data![index]);

                                                    return InkWell(
                                                        onTap: () => {},
                                                        child: Card(
                                                          elevation: Dimens
                                                              .minElevationApplication,
                                                          color: Colors.white,
                                                          margin: EdgeInsets
                                                              .all(Dimens
                                                                  .minMarginApplication),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(Dimens
                                                                    .minRadiusApplication),
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(Dimens
                                                                    .paddingApplication),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: Dimens
                                                                            .marginApplication),
                                                                    child: ClipOval(
                                                                        child: SizedBox.fromSize(
                                                                            size: Size.fromRadius(20),
                                                                            // Image radius
                                                                            child: Image.network(
                                                                              ApplicationConstant.URL_AVATAR /*+
                                                                                  response.avatar.toString()*/
                                                                              ,
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder: (context, exception, stackTrack) => Image.asset(
                                                                                'images/main_logo_1.png',
                                                                              ),
                                                                            )))),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        response
                                                                            .nome,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              Dimens.textSize6,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              Dimens.minMarginApplication),
                                                                      Text(
                                                                        response
                                                                            .descricao,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              Dimens.textSize5,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              Dimens.minMarginApplication),
                                                                      Text(
                                                                        response
                                                                            .data_cadastro,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              Dimens.textSize3,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        AlignmentDirectional
                                                                            .topEnd,
                                                                    child: PopupMenuButton<
                                                                        SampleItemTask>(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .arrow_drop_down_sharp,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      onSelected:
                                                                          (SampleItemTask
                                                                              item) {
                                                                        if (item ==
                                                                            SampleItemTask.itemEdit) {
                                                                          commentEditController.text =
                                                                              response.descricao;

                                                                          showModalBottomSheet<dynamic>(
                                                                              isScrollControlled: true,
                                                                              context: context,
                                                                              shape: Styles().styleShapeBottomSheet,
                                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                              builder: (BuildContext context) {
                                                                                return CommentAlertDialog(
                                                                                  id: response.id.toString(),
                                                                                  commentController: commentEditController,
                                                                                  btnConfirm: Container(
                                                                                    margin: EdgeInsets.only(top: Dimens.marginApplication),
                                                                                    width: double.infinity,
                                                                                    child: ElevatedButton(
                                                                                      style: Styles().styleDefaultButton,
                                                                                      onPressed: () async {
                                                                              /*          if (!validator.validateGenericTextField(commentEditController.text, "Comentário")) return;
*/
                                                                                        setState(() {
                                                                                          _isLoading = true;
                                                                                        });

                                                                                        await updateComment(response.id.toString(), commentEditController.text.toString());

                                                                                        setState(() {
                                                                                          _isLoading = false;
                                                                                        });

                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: (_isLoading)
                                                                                          ? const SizedBox(
                                                                                              width: Dimens.buttonIndicatorWidth,
                                                                                              height: Dimens.buttonIndicatorHeight,
                                                                                              child: CircularProgressIndicator(
                                                                                                color: OwnerColors.colorAccent,
                                                                                                strokeWidth: Dimens.buttonIndicatorStrokes,
                                                                                              ))
                                                                                          : Text("Salvar", style: Styles().styleDefaultTextButton),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                        } else {
                                                                          showModalBottomSheet<
                                                                              dynamic>(
                                                                            isScrollControlled:
                                                                                true,
                                                                            context:
                                                                                context,
                                                                            shape:
                                                                                Styles().styleShapeBottomSheet,
                                                                            clipBehavior:
                                                                                Clip.antiAliasWithSaveLayer,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return GenericAlertDialog(
                                                                                  title: Strings.attention,
                                                                                  content: "Tem certeza que deseja remover este comentário?",
                                                                                  btnBack: TextButton(
                                                                                      child: Text(
                                                                                        Strings.no,
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Inter',
                                                                                          color: Colors.black54,
                                                                                        ),
                                                                                      ),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      }),
                                                                                  btnConfirm: TextButton(
                                                                                      child: Text(Strings.yes),
                                                                                      onPressed: () {
                                                                                        deleteComment(response.id.toString());
                                                                                        Navigator.of(context).pop();
                                                                                      }));
                                                                            },
                                                                          );
                                                                        }
                                                                      },
                                                                      itemBuilder: (BuildContext
                                                                              context) =>
                                                                          <PopupMenuEntry<
                                                                              SampleItemTask>>[
                                                                        const PopupMenuItem<
                                                                            SampleItemTask>(
                                                                          value:
                                                                              SampleItemTask.itemEdit,
                                                                          child:
                                                                              Text('Editar'),
                                                                        ),
                                                                        const PopupMenuItem<
                                                                            SampleItemTask>(
                                                                          value:
                                                                              SampleItemTask.itemDelete,
                                                                          child:
                                                                              Text('Deletar'),
                                                                        ),
                                                                      ],
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                );
                                              } else {
                                                return Container(
                                                    padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            20),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Center(
                                                              child: Lottie.network(
                                                                  height: 160,
                                                                  'https://assets3.lottiefiles.com/private_files/lf30_cgfdhxgx.json')),
                                                          SizedBox(
                                                              height: Dimens
                                                                  .marginApplication),
                                                          Text(
                                                            Strings.empty_list,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: Dimens
                                                                  .textSize5,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ]));
                                              }
                                            } else if (snapshot.hasError) {
                                              return Styles()
                                                  .defaultErrorRequest;
                                            }
                                            return Styles().defaultLoading;
                                          },
                                        )
                                      ])),
                            ],
                          ))
                        ],
                      ),
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          elevation: Dimens.elevationApplication,
                          child: Container(
                            height: 2,
                          ),
                        ),
                        Container(
                            padding:
                                EdgeInsets.all(Dimens.minPaddingApplication),
                            color: OwnerColors.colorPrimaryDark,
                            child: IntrinsicHeight(
                                child: Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  expands: true,
                                  minLines: null,
                                  maxLines: null,
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: OwnerColors.colorPrimary,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    hintText: 'Novo comentário...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimens.radiusApplication),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(
                                        Dimens.textFieldPaddingApplication),
                                  ),
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Dimens.textSize5,
                                  ),
                                )),
                                Expanded(
                                    flex: 0,
                                    child: (_isLoading)
                                        ? Container(
                                            margin: EdgeInsets.all(
                                                Dimens.minMarginApplication),
                                            child: const SizedBox(
                                                width:
                                                    Dimens.buttonIndicatorWidth,
                                                height: Dimens
                                                    .buttonIndicatorHeight,
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      OwnerColors.colorAccent,
                                                  strokeWidth: Dimens
                                                      .buttonIndicatorStrokes,
                                                )))
                                        : Container(
                                            margin: EdgeInsets.only(
                                                left: Dimens
                                                    .minMarginApplication),
                                            child: Wrap(
                                              direction: Axis.horizontal,
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                FloatingActionButton(
                                                  mini: true,
                                                  child: Icon(Icons.send,
                                                      color: Colors.white),
                                                  backgroundColor:
                                                      OwnerColors.colorPrimary,
                                                  onPressed: _isLoading
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });

                                                          await saveComment(
                                                              _id.toString(),
                                                              commentController
                                                                  .text
                                                                  .toString());
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                        },
                                                ),
                                              ],
                                            ),
                                          )),
                              ],
                            )))
                      ],
                    )
                  ]);
                } else if (snapshot.hasError) {
                  return Styles().defaultErrorRequest;
                }
                return Styles().defaultLoading;
              },
            )));
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;

      _isLoading = false;
    });
  }
}
