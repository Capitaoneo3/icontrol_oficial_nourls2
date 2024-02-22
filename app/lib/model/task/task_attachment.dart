
import '../global_ws_model.dart';

class TaskAttachment extends GlobalWSModel{
  final String url;
  final int tipo;
  final String nome;
  final String data_cadastro;

  TaskAttachment({
    required this.url,
    required this.tipo,
    required this.nome,
    required this.data_cadastro, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      url: json['url']?? "",
      tipo: json['tipo']?? 0,
      nome: json['nome']?? "",
      data_cadastro: json['data_cadastro']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}