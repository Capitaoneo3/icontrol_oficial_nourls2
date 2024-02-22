
import 'global_ws_model.dart';

class Fleet extends GlobalWSModel{
  final String url;
  final String nome;
  final String obs;
  final String data_cadastro;
  final int ordem;
  final int tarefas_qtd;


  Fleet({
    required this.url,
    required this.nome,
    required this.obs,
    required this.data_cadastro,
    required this.ordem,
    required this.tarefas_qtd,  required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) {
    return Fleet(
      url: json['url']?? "",
      nome: json['nome']?? "",
      obs: json['obs']?? "",
      data_cadastro: json['data_cadastro']?? "",
      ordem: json['ordem']?? 0,
      tarefas_qtd: json['tarefas_qtd']?? 0,
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}