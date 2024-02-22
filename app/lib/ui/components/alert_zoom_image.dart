import 'package:flutter/material.dart';

import '../../global/application_constant.dart';
import '../../res/dimens.dart';

class ZoomImageAlertDialog extends StatefulWidget {
  String? content;

  ZoomImageAlertDialog({
    Key? key,
    this.content,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<ZoomImageAlertDialog> createState() => _ZoomImageAlertDialogState();
}

class _ZoomImageAlertDialogState extends State<ZoomImageAlertDialog> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(margin: EdgeInsets.all(Dimens.marginApplication), child:
          Align(
              alignment: AlignmentDirectional.topEnd,
              child: GestureDetector(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ))),

         InteractiveViewer(
              panEnabled: false,
              // Set it to false
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2,
              child: Image.network(
                widget.content!,
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width * 0.90,
                errorBuilder: (context, exception, stackTrack) => Image.asset(
                  'images/main_logo_1.png',
                  height: 100,
                  width: 100,
                ),
              ))
    ]));
  }
}
