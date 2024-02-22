import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../res/dimens.dart';

class PickFilesAlertDialog extends StatefulWidget {
  IconButton? iconCamera;
  IconButton? iconGallery;
  IconButton? iconDocument;

  PickFilesAlertDialog({
    Key? key,
    this.iconCamera,
    this.iconGallery,
    this.iconDocument,
  });

  // DialogGeneric({Key? key}) : super(key: key);

  @override
  State<PickFilesAlertDialog> createState() => _PickFilesAlertDialogState();
}

class _PickFilesAlertDialogState extends State<PickFilesAlertDialog> {

  @override
  Widget build(BuildContext context) {

    var widgetItems = <IconButton>[];

    if (widget.iconCamera != null) {
        widgetItems.add(widget.iconCamera!);
    }
    if (widget.iconGallery != null) {
      widgetItems.add(widget.iconGallery!);
    }
    if (widget.iconDocument != null) {
      widgetItems.add(widget.iconDocument!);
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
              padding: const EdgeInsets.all(Dimens.paddingApplication),
              child: Column(children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widgetItems,
                ),
              ])),
        ]);
  }
}
