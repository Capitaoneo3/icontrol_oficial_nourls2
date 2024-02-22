
import 'global_ws_model.dart';

class Photo extends GlobalWSModel{
  final String url;

  Photo({
    required this.url, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      url: json['url']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}