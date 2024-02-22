
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../web_service/service_response.dart';
import '../components/custom_app_bar.dart';

class PdfViewer extends StatefulWidget {

  final String? originRoute;
  final String? url;
  final String? file;

  const PdfViewer ({Key? key, this.originRoute, this.url, this.file}) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewer();
}

class _PdfViewer extends State<PdfViewer> {
  late String _localPath = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // if(widget.url == ''){
    //   PostRequest.loadPDF(widget.file!).then((value) {
    //     setState(() {
    //       _localPath = value;
    //     });
    //   });
    // }else{
      PostRequest.loadPDF("").then((value) {
        setState(() {
          _localPath = value;
        });
      });
    // }

  }
  late PDFViewController _pdfViewController;
  int _pages = 0;
  int _currentPage = 0;


  @override
  Widget build(BuildContext context) {
    print('${widget.url} url aqui');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "Termos de Uso", isVisibleBackButton: true),
      body: _localPath.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          PDFView(
            filePath: _localPath,
            onViewCreated: (PDFViewController controller) {
              _pdfViewController = controller;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
                _pages = total!;
              });
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Text(
              'Páginas: ${_currentPage + 1} ate $_pages',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

}




