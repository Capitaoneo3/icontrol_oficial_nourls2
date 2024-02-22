
import 'global_ws_model.dart';

class SearchQuery extends GlobalWSModel{
  final String cidade;
  final String nome_fantasia;
  final String descricao;
  final String email;
  final String documento;
  final String celular;
  final String avatar;
  final String cep;
  final String uf;
  final String estado;
  final String endereco;
  final String bairro;
  final String numero;
  final String complemento;
  final dynamic latitude;
  final dynamic longitude;

  SearchQuery({
    required this.nome_fantasia,
    required this.descricao,
    required this.email,
    required this.documento,
    required this.celular,
    required this.avatar,
    required this.cep,
    required this.uf,
    required this.estado,
    required this.endereco,
    required this.bairro,
    required this.numero,
    required this.complemento,
    required this.latitude,
    required this.longitude,
    required this.cidade,  required super.status, required super.msg, required super.id, required super.rows,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      nome_fantasia: json['nome_fantasia']?? "",
      descricao: json['descricao']?? "",
      email: json['email']?? "",
      documento: json['documento']?? "",
      celular: json['celular']?? "",
      avatar: json['avatar']?? "",
      cep: json['cep']?? "",
      uf: json['uf']?? "",
      estado: json['estado']?? "",
      cidade: json['cidade']?? "",
      endereco: json['endereco']?? "",
      bairro: json['bairro']?? "",
      numero: json['numero']?? "",
      complemento: json['complemento']?? "",
      latitude: json['latitude']?? "",
      longitude: json['longitude']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

}