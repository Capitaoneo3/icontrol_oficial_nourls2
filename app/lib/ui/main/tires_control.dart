import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../res/dimens.dart';
import '../../res/owner_colors.dart';
import '../../res/strings.dart';
import '../components/custom_app_bar.dart';

class TiresControl extends StatefulWidget {
  const TiresControl({Key? key}) : super(key: key);

  @override
  State<TiresControl> createState() => _TiresControl();
}

class _TiresControl extends State<TiresControl> {
  bool _isLoading = false;

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          CustomAppBar(title: "Controle de pneus", isVisibleBackButton: false),
      body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: /*FutureBuilder<List<Map<String, dynamic>>>(
            future: listOrders(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // final responseItem = Order.fromJson(snapshot.data![0]);

                if (responseItem.rows != 0) {
                  return */
              ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              // final response = Order.fromJson(snapshot.data![index]);

              // Pendente,Aprovado,Rejeitado,Cancelado,Devolvido

              var _statusColor = OwnerColors.lightGrey;

              // switch (response.status_pagamento) {
              //   case "Pendente":
              //     _statusColor = OwnerColors.darkGrey;
              //     break;
              //   case "Aprovado":
              //
              //     _statusColor = OwnerColors.colorPrimaryDark;
              //     break;
              //   case "Rejeitado":
              //
              //     _statusColor = Colors.yellow[700];
              //     break;
              //   case "Cancelado":
              //
              //     _statusColor = Colors.red;
              //     break;
              //   case "Devolvido":
              //
              //     _statusColor = OwnerColors.darkGrey;
              //     break;
              // }

              return InkWell(
                  onTap: () => {
                        // Navigator.pushNamed(
                        //     context, "/ui/order_detail",
                        //     arguments: {
                        //       "id": response.id,
                        //     })
                      },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimens.minRadiusApplication),
                    ),
                    margin: EdgeInsets.all(Dimens.minMarginApplication),
                    child: Container(
                      padding: EdgeInsets.all(Dimens.paddingApplication),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Strings.littleLoremIpsum,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Text(
                                  Strings.littleLoremIpsum,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize4,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimens.marginApplication),
                                Text(
                                  "Ver detalhes",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: Dimens.textSize4,
                                    color: OwnerColors.colorPrimary,
                                  ),
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Divider(
                                  color: Colors.black12,
                                  height: 2,
                                  thickness: 1.5,
                                ),
                                SizedBox(height: Dimens.minMarginApplication),
                                Align(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    child: Card(
                                        color: _statusColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimens.minRadiusApplication),
                                        ),
                                        child: Container(
                                            padding: EdgeInsets.all(
                                                Dimens.minPaddingApplication),
                                            child: Text(
                                              "status",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: Dimens.textSize5,
                                                color: Colors.white,
                                              ),
                                            )))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
            },
          )
          /* } else {
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
                return Text('${snapshot.error}');
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
     */
          ),
    );
  }
}
