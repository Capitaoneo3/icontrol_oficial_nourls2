
import '../global_ws_model.dart';

class Task extends GlobalWSModel{
  final String url;
  final String nome;
  final int frota;
  final String descricao;
  final String obs_checklist;
  final int id_status;
  final String nome_status;
  final int id_equipamento;
  final String nome_equipamento;
  final String data_cadastro;
  final String horimetro;
  final String cor_entrega;
  final int ordem;
  final String cor;
  final String cor_status;
  final String data_in;
  final String data_out;
  final String data_in_hora;
  final String data_out_hora;
  final dynamic id_tarefa;
  final dynamic id_frota;
  final String msg_entrega;

  Task({
    required this.url,
    required this.nome,
    required this.frota,
    required this.descricao,
    required this.obs_checklist,
    required this.id_status,
    required this.nome_status,
    required this.id_equipamento,
    required this.nome_equipamento,
    required this.data_cadastro,
    required this.horimetro,
    required this.cor_entrega,
    required this.ordem,
    required this.cor,
    required this.cor_status,
    required this.data_in,
    required this.data_out,
    required this.data_in_hora,
    required this.data_out_hora,
    required this.id_tarefa,
    required this.id_frota,
    required this.msg_entrega, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      url: json['url']?? "",
      nome: json['nome']?? "",
      frota: json['frota']?? 0,
      descricao: json['descricao']?? "",
      obs_checklist: json['obs_checklist']?? "",
      id_status: json['id_status']?? 0,
      nome_status: json['nome_status']?? "",
      id_equipamento: json['id_equipamento']?? 0,
      nome_equipamento: json['nome_equipamento']?? "",
      data_cadastro: json['data_cadastro']?? "",
      horimetro: json['horimetro']?? "",
      cor_entrega: json['cor_entrega']?? "",
      ordem: json['ordem']?? 0,
      cor: json['cor']?? "",
      cor_status: json['cor_status']?? "",
      data_in: json['data_in']?? "",
      data_out: json['data_out']?? "",
      data_in_hora: json['data_in_hora']?? "",
      data_out_hora: json['data_out_hora']?? "",
      id_tarefa: json['id_tarefa']?? 0,
      id_frota: json['id_frota']?? 0,
      msg_entrega: json['msg_entrega']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}