import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icontrol/model/employee.dart';
import 'package:icontrol/model/equipment.dart';
import 'package:icontrol/model/search.dart';
import 'package:icontrol/model/task/task.dart';

import '../../config/application_messages.dart';
import '../../config/preferences.dart';
import '../../global/application_constant.dart';
import '../../model/brand.dart';
import '../../model/fleet.dart';
import '../../model/model.dart';
import '../../model/payment.dart';
import '../../model/user.dart';
import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/styles.dart';
import '../../web_service/links.dart';
import '../../web_service/service_response.dart';
import '../components/alert_dialog_info.dart';
import '../components/custom_app_bar.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _Search();
}

class _Search extends State<Search> {
  bool _isLoading = false;

  final postRequest = PostRequest();

  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController hashTagController = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<Marker> mMarkers = [];
  List<String> mSuggestions = [];

  @override
  void initState() {
    listAll();
    getCityNameFormatted("");
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition _actualLocation = CameraPosition(
    target: LatLng(-15.143368545427352, -52.087151980187905),
    zoom: Dimens.zoomMap,
  );

  Future<void> _go(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_actualLocation));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<List<Map<String, dynamic>>> listAll(
      {String? hashtag, String? cityName}) async {
    mMarkers.clear();

    try {
      var body = {
        "cidade": cityName ?? "",
        "hashtag": hashtag ?? "",
        "token": ApplicationConstant.TOKEN
      };

      print('HTTP_BODY: $body');

      final json =
          await postRequest.sendPostRequest(Links.SEARCH_INTERPRISES, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final responseItem = SearchQuery.fromJson(_map[0]);

      if (responseItem.rows != 0) {
        final Uint8List markerIcon =
            await getBytesFromAsset('images/little_icon.png', 100);

        for (var i = 0; i < _map.length; i++) {
          final response = SearchQuery.fromJson(_map[i]);

          mMarkers.add(
            Marker(
              visible: true,
              icon: BitmapDescriptor.fromBytes(markerIcon),
              // infoWindow: InfoWindow(
              //   title: response.nome! /* + "\nCódigo: " + response.codigo!*/,
              //   onTap: () {
              //     _actualItem = response;
              //     setState(() {
              //
              //     });
              //   },
              // ),
              onTap: () {
                showModalBottomSheet<dynamic>(
                  isScrollControlled: true,
                  context: context,
                  shape: Styles().styleShapeBottomSheet,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (BuildContext context) {
                    return InfoAlertDialog(id: response.id.toString());
                  },
                );
              },
              markerId: MarkerId(response.id.toString()),
              position: LatLng(
                  double.parse(
                      response.latitude.toString().replaceAll(",", ".")),
                  double.parse(
                      response.longitude.toString().replaceAll(",", "."))),
            ),
          );

          // if (i == _map.length) {
          //   _go(LatLng(
          //       double.parse(response.latitude.toString().replaceAll(",", ".")),
          //       double.parse(
          //           response.longitude.toString().replaceAll(",", "."))));
          // }
        }

        setState(() {});
      }

      return _map;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  Future<String> getCityNameFormatted(String? cityName) async {
    // if (cityName == null) {
    //   return "";
    // }

    try {
      var body = {"cidade": cityName, "token": ApplicationConstant.TOKEN};

      print('HTTP_BODY: $body');

      final json = await postRequest.sendPostRequest(Links.SEARCH_CITIES, body);

      List<Map<String, dynamic>> _map = [];
      _map = List<Map<String, dynamic>>.from(jsonDecode(json));

      print('HTTP_RESPONSE: $_map');

      final response = SearchQuery.fromJson(_map[0]);

      if (response.rows == 0) {
        ApplicationMessages(context: context)
            .showMessage("Não foi possível determinar uma lista de cidades.");
      } else {

        mSuggestions.clear();

        for (var i = 0; i < _map.length; i++) {
          final response = SearchQuery.fromJson(_map[i]);

          mSuggestions.add(response.cidade);
          }
      }

      return response.cidade;
    } catch (e) {
      throw Exception('HTTP_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _actualLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            scrollGesturesEnabled: true,
            compassEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            markers: mMarkers.toSet(),
            zoomControlsEnabled: false,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: Dimens.marginApplication),
            padding: EdgeInsets.all(Dimens.paddingApplication),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              // FloatingActionButton(
              //     onPressed: () {
              //       Navigator.pushNamed(context, "/ui/notifications");
              //     },
              //     child: Icon(
              //       Icons.notifications_rounded,
              //       color: OwnerColors.colorPrimaryDark,
              //       size: 24,
              //     ),
              //     backgroundColor: Colors.white,
              //     mini: true),
              SizedBox(
                height: Dimens.marginApplication,
              ),
              SimpleAutoCompleteTextField(
                key: key,
                suggestions: mSuggestions,
                controller: cityNameController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: OwnerColors.colorPrimary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: 'Pesquisar pela cidade...',
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
                height: Dimens.marginApplication,
              ),

              TextField(
                controller: hashTagController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: OwnerColors.colorPrimary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: 'Pesquisar por tag...',
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
                    setState(() {
                      _isLoading = true;
                    });

                    await listAll(
                        hashtag: hashTagController.text,
                        cityName: cityNameController.text);

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
                      : Text("Filtrar", style: Styles().styleDefaultTextButton),
                ),
              ),
            ]),
          ),
        ]));
  }
}
