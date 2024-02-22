
import 'global_ws_model.dart';

class Model extends GlobalWSModel{
  final String url;
  final String nome;

  Model({
    required this.url,
    required this.nome, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      url: json['url']?? "",
      nome: json['nome']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}