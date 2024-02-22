
import 'global_ws_model.dart';

class User extends GlobalWSModel{
  final String nome;
  final String email;
  final String documento;
  final String celular;
  final String avatar;
  final String cep;
  final String uf;
  final String cidade;
  final String estado;
  final String endereco;
  final String bairro;
  final String numero;
  final String complemento;
  final dynamic latitude;
  final dynamic longitude;
  final String endereco_completo;
  final String descricao;
  final String data;
  final String titulo;
  final String logradouro;
  final String localidade;
  final String tipo_pessoa;
  final int saldo_aprovado;
  final String type;
  final int tipo;
  final String cpf;
  final String cnpj;
  final int id_empresa;
  final String mensagem;
  final int plano_id;
  final String plano_nome;
  final int tempo_total_dias;
  final int tempo_restante_dias;
  final int tempo_restante_horas;
  final int tempo_restante_minutos;
  final String valor;
  final String nome_fantasia;
  final String razao_social;
  final int dias;
  final String obs;
  final String expiracao_validade;





  User({
    required this.nome,
    required this.email,
    required this.documento,
    required this.celular,
    required this.avatar,
    required this.cep,
    required this.uf,
    required this.estado,
    required this.cidade,
    required this.endereco,
    required this.bairro,
    required this.numero,
    required this.complemento,
    required this.latitude,
    required this.longitude,
    required this.endereco_completo,
    required this.descricao,
    required this.data,
    required this.titulo,
    required this.logradouro,
    required this.localidade,
    required this.tipo_pessoa,
    required this.saldo_aprovado,
    required this.type,
    required this.tipo,
    required this.cpf,
    required this.cnpj,
    required this.id_empresa,
    required this.mensagem,
    required this.plano_id,
    required this.plano_nome,
    required this.tempo_total_dias,
    required this.tempo_restante_dias,
    required this.tempo_restante_horas,
    required this.tempo_restante_minutos,
    required this.valor,
    required this.nome_fantasia,
    required this.razao_social,
    required this.dias,
    required this.obs,
    required this.expiracao_validade, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nome: json['nome']?? "",
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
      endereco_completo: json['endereco_completo']?? "",
      descricao: json['descricao']?? "",
      data: json['data']?? "",
      titulo: json['titulo']?? "",
      localidade: json['localidade']?? "",
      logradouro: json['logradouro']?? "",
      tipo_pessoa: json['tipo_pessoa']?? "",
      saldo_aprovado: json['saldo_aprovado']?? 0,
      type: json['type']?? "",
      tipo: json['tipo']?? 0,
      cpf: json['cpf']?? "",
      cnpj: json['cnpj']?? "",
      id_empresa: json['id_empresa']?? 0,
      mensagem: json['mensagem']?? "",
      plano_id: json['plano_id']?? 0,
      plano_nome: json['plano_nome']?? "",
      tempo_total_dias: json['tempo_total_dias']?? 0,
      tempo_restante_dias: json['tempo_restante_dias']?? 0,
      tempo_restante_horas: json['tempo_restante_horas']?? 0,
      tempo_restante_minutos: json['tempo_restante_minutos']?? 0,
      valor: json['valor']?? "",
      nome_fantasia: json['nome_fantasia']?? "",
      razao_social: json['razao_social']?? "",
      dias: json['dias']?? 0,
      obs: json['obs']?? "",
      expiracao_validade: json['expiracao_validade']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? "",
      rows: json['rows']?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'documento': documento,
      'celular': celular,
      'avatar': avatar,
      'tipo': tipo,
      'id_empresa': id_empresa,
      'status': status,
      'msg': msg,
      'id': id,
      'rows': rows,
    };
  }
}