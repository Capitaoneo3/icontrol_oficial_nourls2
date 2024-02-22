
import '../global_ws_model.dart';

class TaskComment extends GlobalWSModel{
  final String url;
  final String descricao;
  final String nome;
  final String data_cadastro;


  TaskComment({
    required this.url,
    required this.descricao,
    required this.nome,
    required this.data_cadastro, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      descricao: json['descricao']?? "",
      nome: json['nome']?? "",
      data_cadastro: json['data_cadastro']?? "",
      url: json['url']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}