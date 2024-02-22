
import '../global_ws_model.dart';

class TaskChecklist extends GlobalWSModel{
  final String url;
  final String nome;
  final int check;
  final int id_checklist;
  final dynamic perc_progresso;
  final String previsao;
  final String horimetro;




  TaskChecklist({
    required this.url,
    required this.nome,
    required this.check,
    required this.id_checklist,
    required this.perc_progresso,
    required this.previsao,
    required this.horimetro, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory TaskChecklist.fromJson(Map<String, dynamic> json) {
    return TaskChecklist(
      url: json['url']?? "",
      nome: json['nome']?? "",
      check: json['check']?? 0,
      id_checklist: json['id_checklist']?? 0,
      perc_progresso: json['perc_progresso']?? 0,
      previsao: json['previsao']?? "",
      horimetro: json['horimetro']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}