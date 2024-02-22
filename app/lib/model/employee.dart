
import 'global_ws_model.dart';

class Employee extends GlobalWSModel{
  final String url;
  final String nome;
  final String email;
  final String celular;
  final String avatar;
  final String cpf;
  final String data_nascimento;

  Employee({
    required this.url,
    required this.nome,
    required this.email,
    required this.celular,
    required this.avatar,
    required this.cpf,
    required this.data_nascimento, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      url: json['url']?? "",
      nome: json['nome']?? "",
      email: json['email']?? "",
      celular: json['celular']?? "",
      avatar: json['avatar']?? "",
      cpf: json['cpf']?? "",
      data_nascimento: json['data_nascimento']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}