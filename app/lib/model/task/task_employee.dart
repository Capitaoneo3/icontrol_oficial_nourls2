
import '../global_ws_model.dart';

class TaskEmployee extends GlobalWSModel{
  final String url;
  final String nome;
  final String avatar;

  TaskEmployee({
    required this.url,
    required this.nome,
    required this.avatar, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory TaskEmployee.fromJson(Map<String, dynamic> json) {
    return TaskEmployee(
      url: json['url']?? "",
      nome: json['nome']?? "",
      avatar: json['avatar']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}