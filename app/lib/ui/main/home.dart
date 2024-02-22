import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icontrol/res/styles.dart';
import 'package:icontrol/ui/components/alert_dialog_add_task.dart';
import 'package:lottie/lottie.dart';

import '../../config/application_messages.dart';
import '../../config/preferences.dart';
import '../../config/validator.dart';
import '../../global/application_constant.dart';
import '../../model/fleet.dart';
import '../../model/task/task.dart';
import '../../model/task/task_employee.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';
import '../components/alert_dialog_generic.dart';
import '../components/custom_app_bar.dart';
import '../components/dot_indicator.dart';
import 'tires_control.dart';
import 'search.dart';
import 'main_menu.dart';
import 'plan.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    var widgetItems = <Widget>[];

    widgetItems.add(ContainerHome());
    widgetItems.add(TiresControl());
 /*   if (Preferences.getUserData()!.tipo == 1) {
      widgetItems.add(Plan());
    }*/
    widgetItems.add(Search());
    widgetItems.add(MainMenu());

    List<Widget> _widgetOptions = widgetItems;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar:
          BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}

class ContainerHome extends StatefulWidget {
  const ContainerHome({Key? key}) : super(key: key);

  @override
  State<ContainerHome> createState() => _ContainerHomeState();
}

GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  BottomNavBar({this.currentIndex = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var bottomNavigationBarItems = <BottomNavigationBarItem>[];

    bottomNavigationBarItems.add(BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: Strings.home,
    ));
    bottomNavigationBarItems.add(BottomNavigationBarItem(
      icon: Icon(Icons.tire_repair),
      label: Strings.tire,
    ));
   /* if (Preferences.getUserData()!.tipo == 1) {
      bottomNavigationBarItems.add(BottomNavigationBarItem(
        icon: Icon(Icons.shield_outlined),
        label: Strings.plan,
      ));
    }*/
    bottomNavigationBarItems.add(BottomNavigationBarItem(
    icon: Icon(Icons.map_outlined),
    label: Strings.search,
    ));
    bottomNavigationBarItems.add(BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: Strings.menu,
    ));
    return BottomNavigationBar(
        key: globalKey,
        elevation: Dimens.elevationApplication,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: OwnerColors.colorPrimary,
        selectedItemColor: OwnerColors.colorAccent,
        unselectedItemColor: OwnerColors.lightGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: bottomNavigationBarItems);
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

enum SampleItemTask { itemDetails, itemDelete }

class _ContainerHomeState extends State<ContainerHome> {
  bool _isLoading = false;
  bool _isLoadingDialog = false;

  SampleItem? selectedMenu;

  late Validator validator;
  final postRequest = PostRequest();

  @override
  void initState() {
    validator = Validator(context: context);
    //saveFcm();

  /*  if (Preferences.getUserData()!.tipo != 2) {

      verifyPlan();
    }*/
    super.initState();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  @override
  void dispose() {
    categoryController.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> updateSequence(
      String idTask, String idFleet, String type) async {
    try {
      final body = {
        "id_tarefa": idTask,
        "id_frota": idFleet,
        "tipo": type,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.UPDATE_SEQUENCE_TASKS, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Fleet.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
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

  Future<Map<String, dynamic>> deleteTask(String idTask) async {
    try {
      final body = {"id_tarefa": idTask, "token": ApplicationConstant.TOKEN};

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.DELETE_TASK, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      setState(() {});

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> saveTask(String idFleet, String idEquip,
      String name, String desc, String checklist) async {
    try {
      final body = {
        "id_frota": idFleet,
        "id_equipamento": idEquip,
        // "nome": name,
        // "descricao": desc,
        // "checklist": checklist,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.SAVE_TASK, body);
      final parsedResponse = jsonDecode(json);

      print('HTTP_RESPONSE: $parsedResponse');

      final response = Task.fromJson(parsedResponse);

      Navigator.of(context)
          .pop();

      if (response.status == "01") {

        Navigator.pushNamed(
            context,
            "/ui/task_detail",
            arguments: {
              "id":
              response.id_tarefa,
              "id_fleet":
              int.parse(response.id_frota),
            });
      } else {}
      ApplicationMessages(context: context).showMessage(response.msg);

      return parsedResponse;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listTasks(String idFleet) async {
    try {
      final body = {
        "frota_id": idFleet,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_TASKS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Task.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listFleets() async {
    try {
      final body = {
        "id_user": Preferences.getUserData()!.tipo != 1 ? await Preferences.getUserData()!.id_empresa : await Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.LIST_FLEETS, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = Fleet.fromJson(_map[0]);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<List<Map<String, dynamic>>> verifyPlan() async {
    try {
      final body = {
        "id_user": Preferences.getUserData()!.id,
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.VERIFY_PLAN, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);
      if (response.status != "01") {
        var navigationBar = globalKey.currentWidget as BottomNavigationBar;
        navigationBar.onTap!(2);
      } else {}
      // ApplicationMessages(context: context).showMessage(response.mensagem);

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<void> saveFcm() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    try {
      await Preferences.init();
      String? savedFcmToken = await Preferences.getInstanceTokenFcm();
      String? currentFcmToken = await _firebaseMessaging.getToken();
      if (savedFcmToken != null && savedFcmToken == currentFcmToken) {
        print('FCM: não salvou');
        return;
      }

      var _type = "";

      if (Platform.isAndroid) {
        _type = ApplicationConstant.FCM_TYPE_ANDROID;
      } else if (Platform.isIOS) {
        _type = ApplicationConstant.FCM_TYPE_IOS;
      } else {
        return;
      }

      final body = {
        "id_user": await Preferences.getUserData()!.id,
        "type": _type,
        "registration_id": currentFcmToken,
        "token": ApplicationConstant.TOKEN,
      };

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.SAVE_FCM, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = User.fromJson(_map[0]);

      if (response.status == "01") {
        await Preferences.saveInstanceTokenFcm("token", currentFcmToken!);
        setState(() {});
      } else {}
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: "Início",
          isVisibleBackButton: false,
          isVisibleSearchButton: true,
          isVisibleNotificationsButton: true,
          // isVisibleTaskAddButton: true,
        ),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: listFleets(),
              builder: (context, snapshot) {
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
                if (snapshot.hasData) {
                  final responseItem = Task.fromJson(snapshot.data![0]);

                  if (responseItem.rows != 0) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final responseFleet =
                            Fleet.fromJson(snapshot.data![index]);

                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Card(
                                elevation: Dimens.minElevationApplication,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimens.radiusApplication),
                                ),
                                margin:
                                    EdgeInsets.all(Dimens.minMarginApplication),
                                child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.80,
                                    child: Wrap(
                                      children: [
                                        Column(children: [
                                          Row(children: [
                                            Expanded(
                                                child: Container(
                                              child: Text(
                                                responseFleet.nome + " (" + responseFleet.tarefas_qtd.toString() + ")",
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: Dimens.textSize7,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: Dimens.marginApplication,
                                                  left:
                                                      Dimens.marginApplication,
                                                  bottom: Dimens
                                                      .minMarginApplication),
                                            )),
                                            // PopupMenuButton<SampleItem>(
                                            //   initialValue: selectedMenu,
                                            //   // Callback that sets the selected popup menu item.
                                            //   onSelected: (SampleItem item) {
                                            //     setState(() {
                                            //       selectedMenu = item;
                                            //     });
                                            //   },
                                            //   itemBuilder: (BuildContext
                                            //           context) =>
                                            //       <PopupMenuEntry<SampleItem>>[
                                            //     const PopupMenuItem<SampleItem>(
                                            //       value: SampleItem.itemOne,
                                            //       child: Text('Item 1'),
                                            //     ),
                                            //     const PopupMenuItem<SampleItem>(
                                            //       value: SampleItem.itemTwo,
                                            //       child: Text('Item 2'),
                                            //     ),
                                            //     const PopupMenuItem<SampleItem>(
                                            //       value: SampleItem.itemThree,
                                            //       child: Text('Item 3'),
                                            //     ),
                                            //   ],
                                            // ),
                                          ]),
                                          ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height - (kToolbarHeight + kBottomNavigationBarHeight * 3.3)),
                                              child: SingleChildScrollView(
                                                  child: Column(children: [
                                                Image.network(
                                                  ApplicationConstant
                                                          .URL_FLEETS +
                                                      responseFleet.url
                                                          .toString(),
                                                  height: 190,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                          exception,
                                                          stackTrack) =>
                                                      Image.asset(
                                                    'images/main_logo_1.png',
                                                    width: double.infinity,
                                                    height: 190,
                                                  ),
                                                ),
                                                FutureBuilder<
                                                    List<Map<String, dynamic>>>(
                                                  future: listTasks(
                                                      responseFleet.id
                                                          .toString()),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      final responseItem =
                                                          Task.fromJson(snapshot
                                                              .data![0]);

                                                      if (responseItem.rows !=
                                                          0) {
                                                        return ListView.builder(
                                                          primary: false,
                                                          shrinkWrap: true,
                                                          itemCount: snapshot
                                                              .data!.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final response =
                                                                Task.fromJson(
                                                                    snapshot.data![
                                                                        index]);

                                                            var color = response
                                                                .cor_status
                                                                .replaceAll(
                                                                    "#", "");

                                                            var colorDate =
                                                                response
                                                                    .cor_entrega
                                                                    .replaceAll(
                                                                        "#",
                                                                        "");

                                                            return InkWell(
                                                                onTap: () => {
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          "/ui/task_detail",
                                                                          arguments: {
                                                                            "id":
                                                                                response.id,
                                                                            "id_fleet":
                                                                                responseFleet.id,
                                                                          })
                                                                    },
                                                                child: Card(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimens.minRadiusApplication),
                                                                  ),
                                                                  margin: EdgeInsets
                                                                      .all(Dimens
                                                                          .minMarginApplication),
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets
                                                                        .all(Dimens
                                                                            .minPaddingApplication),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        // Container(
                                                                        //     margin: EdgeInsets.only(
                                                                        //         right: Dimens.minMarginApplication),
                                                                        //     child: ClipRRect(
                                                                        //         borderRadius: BorderRadius.circular(
                                                                        //             Dimens.minRadiusApplication),
                                                                        //         child: Image.asset(
                                                                        //           'images/person.jpg',
                                                                        //           height: 90,
                                                                        //           width: 90,
                                                                        //         ))),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Align(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  child: Card(
                                                                                      color: Color(int.parse("0xFF$color")),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                                                                                      ),
                                                                                      child: Container(
                                                                                          padding: EdgeInsets.all(Dimens.minPaddingApplication),
                                                                                          child: Text(
                                                                                            response.nome_status,
                                                                                            style: TextStyle(
                                                                                              fontFamily: 'Inter',
                                                                                              fontSize: Dimens.textSize5,
                                                                                              color: Colors.white,
                                                                                            ),
                                                                                          )))),
                                                                              Container(
                                                                                  margin: EdgeInsets.only(left: 5),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      SizedBox(height: Dimens.minMarginApplication),
                                                                                      Text(
                                                                                        response.nome,
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Inter',
                                                                                          fontSize: Dimens.textSize5,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Colors.black,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: Dimens.minMarginApplication),
                                                                                      Text(
                                                                                        "Equipamento: " + response.nome_equipamento,
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Inter',
                                                                                          fontSize: Dimens.textSize4,
                                                                                          color: Colors.black,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: Dimens.minMarginApplication),
                                                                                      SizedBox(height: Dimens.minMarginApplication),
                                                                                      Visibility(
                                                                                          visible: response.data_out != null && response.data_out_hora != null,
                                                                                          child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "Data de entrega: ",
                                                                                                style: TextStyle(
                                                                                                  fontFamily: 'Inter',
                                                                                                  fontSize: Dimens.textSize4,
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                              Align(
                                                                                                  alignment: AlignmentDirectional.bottomStart,
                                                                                                  child: Card(
                                                                                                      color: Color(int.parse("0xFF$colorDate")),
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                                                                                                      ),
                                                                                                      child: Row(
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
                                                                                                                response.data_out.toString() + " - " + response.data_out_hora.toString(),
                                                                                                                style: TextStyle(
                                                                                                                  fontFamily: 'Inter',
                                                                                                                  fontSize: Dimens.textSize4,
                                                                                                                  color: Colors.white,
                                                                                                                ),
                                                                                                              ))
                                                                                                        ],
                                                                                                      ))),
                                                                                            ],
                                                                                          ))
                                                                                    ],
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                      margin: EdgeInsets.all(2),
                                                                                      child: InkWell(
                                                                                          onTap: () {
                                                                                            updateSequence(response.id.toString(), responseFleet.id.toString(), "2");
                                                                                          },
                                                                                          child: Card(
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                                                                                            ),
                                                                                            color: Colors.white,
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.all(Dimens.minPaddingApplication),
                                                                                              child: Icon(Icons.arrow_upward_sharp, size: 20, color: OwnerColors.darkGrey),
                                                                                            ),
                                                                                          ))),
                                                                                  Container(
                                                                                      margin: EdgeInsets.all(2),
                                                                                      child: InkWell(
                                                                                          onTap: () {
                                                                                            updateSequence(response.id.toString(), responseFleet.id.toString(), "1");
                                                                                          },
                                                                                          child: Card(
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(Dimens.minRadiusApplication),
                                                                                            ),
                                                                                            color: Colors.white,
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.all(Dimens.minPaddingApplication),
                                                                                              child: Icon(Icons.arrow_downward_sharp, size: 20, color: OwnerColors.darkGrey),
                                                                                            ),
                                                                                          ))),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: Dimens.minMarginApplication),
                                                                              FutureBuilder<List<Map<String, dynamic>>>(
                                                                                future: listTaskEmployees(response.id.toString()),
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.hasData) {
                                                                                    final responseItem = TaskEmployee.fromJson(snapshot.data![0]);

                                                                                    if (responseItem.rows != 0) {
                                                                                      var gridItems = <Widget>[];

                                                                                      for (var i = 0; i < snapshot.data!.length; i++) {
                                                                                        final response = TaskEmployee.fromJson(snapshot.data![i]);

                                                                                        if (i < 3) {
                                                                                          if (i > 1) {
                                                                                            gridItems.add(Container(
                                                                                                margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                                                                                child: ClipOval(
                                                                                                    child: SizedBox.fromSize(
                                                                                                  size: Size.fromRadius(10),
                                                                                                  // Image radius
                                                                                                  child: Icon(Icons.more_horiz),
                                                                                                ))));
                                                                                          } else {
                                                                                            gridItems.add(Container(
                                                                                                margin: EdgeInsets.only(right: Dimens.minMarginApplication),
                                                                                                child: ClipOval(
                                                                                                    child: SizedBox.fromSize(
                                                                                                        size: Size.fromRadius(16),
                                                                                                        // Image radius
                                                                                                        child: Image.network(
                                                                                                          ApplicationConstant.URL_AVATAR + response.avatar.toString(),
                                                                                                          fit: BoxFit.cover,
                                                                                                          errorBuilder: (context, exception, stackTrack) => Image.asset(
                                                                                                            'images/main_logo_1.png',
                                                                                                          ),
                                                                                                        )))));
                                                                                          }
                                                                                        }
                                                                                      }

                                                                                      return Row(
                                                                                        children: gridItems,
                                                                                      );
                                                                                    } else {
                                                                                      return Container();
                                                                                    }
                                                                                  } else if (snapshot.hasError) {
                                                                                    return Container();
                                                                                  }
                                                                                  return Container();
                                                                                },
                                                                              ),
                                                                            ])
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                          },
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Styles()
                                                          .defaultErrorRequest;
                                                    }
                                                    return Styles()
                                                        .defaultLoading;
                                                  },
                                                )
                                              ]))),
                                          InkWell(
                                              onTap: () {
                                                showModalBottomSheet<dynamic>(
                                                    isScrollControlled: true,
                                                    context: context,
                                                    shape: Styles()
                                                        .styleShapeBottomSheet,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AddTaskAlertDialog(
                                                        categoryController:
                                                            categoryController,
                                                        titleController:
                                                            titleController,
                                                        descController:
                                                            descController,
                                                        btnConfirm: Container(
                                                          margin: EdgeInsets.only(
                                                              top: Dimens
                                                                  .marginApplication),
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                            style: Styles()
                                                                .styleDefaultButton,
                                                            onPressed:
                                                                _isLoadingDialog
                                                                    ? null
                                                                    : () async {
                                                                        // if (!validator.validateGenericTextField(
                                                                        //     titleController
                                                                        //         .text,
                                                                        //     "Título"))
                                                                        //   return;

                                                                        if (categoryController.text ==
                                                                            "") {
                                                                          ApplicationMessages(context: context)
                                                                              .showMessage("É necessário adicionar um equipamento!");
                                                                          return;
                                                                        }
                                                                        // if (!validator.validateGenericTextField(
                                                                        //     titleController
                                                                        //         .text,
                                                                        //     "Descrição"))
                                                                        //   return;

                                                                        setState(
                                                                            () {
                                                                          _isLoadingDialog =
                                                                              true;
                                                                        });

                                                                        await saveTask(
                                                                            responseFleet.id.toString(),
                                                                            categoryController.text,
                                                                            titleController.text,
                                                                            descController.text,
                                                                            "");

                                                                        setState(
                                                                            () {
                                                                          _isLoadingDialog =
                                                                              false;
                                                                        });


                                                                      },
                                                            child:
                                                                (_isLoadingDialog)
                                                                    ? const SizedBox(
                                                                        width: Dimens
                                                                            .buttonIndicatorWidth,
                                                                        height: Dimens
                                                                            .buttonIndicatorHeight,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              OwnerColors.colorAccent,
                                                                          strokeWidth:
                                                                              Dimens.buttonIndicatorStrokes,
                                                                        ))
                                                                    : Text(
                                                                        "Adicionar tarefa",
                                                                        style: Styles()
                                                                            .styleDefaultTextButton),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: OwnerColors
                                                        .colorPrimary,
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight: Radius
                                                            .circular(Dimens
                                                                .radiusApplication),
                                                        bottomLeft: Radius
                                                            .circular(Dimens
                                                                .radiusApplication)),
                                                  ),
                                                  alignment: Alignment.center,
                                                  width: double.infinity,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        size: 24,
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                      Text("Adicionar card",
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: Dimens
                                                                .textSize6,
                                                            color: Colors.white,
                                                          )),
                                                    ],
                                                  )))
                                        ])
                                      ],
                                    )),
                              ),
                            ]);
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
            )));
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;
      // listHighlightsRequest();
      _isLoading = false;
    });
  }
}
