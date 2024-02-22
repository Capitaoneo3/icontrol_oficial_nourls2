

import 'global_ws_model.dart';

class Payment extends GlobalWSModel{
  final String nome;
  final String email;
  final String url_foto;
  final String descricao;
  final String valor;
  final String valor_frete;
  final String valor_total;
  final String status_pagamento;
  final String nome_status_pedido;
  final int id_usuario;
  final String nome_usuario;
  final String email_usuario;
  final String documento_usuario;
  final int tipo_pagamento;
  final String url_pagamento;
  final String qrcode_pagamento;
  final String valor_pagamento;
  final String data_pagamento;
  final String qrcode;
  final String qrcode_64;
  final String cod_barras;



  Payment({
    required this.nome,
    required this.email,
    required this.url_foto,
    required this.descricao,
    required this.valor,
    required this.valor_frete,
    required this.valor_total,
    required this.status_pagamento,
    required this.nome_status_pedido,
    required this.id_usuario,
    required this.nome_usuario,
    required this.email_usuario,
    required this.documento_usuario,
    required this.tipo_pagamento,
    required this.url_pagamento,
    required this.qrcode_pagamento,
    required this.valor_pagamento,
    required this.data_pagamento,
    required this.qrcode,
    required this.qrcode_64,
    required this.cod_barras, required super.status, required super.msg, required super.id, required super.rows,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      nome: json['nome']?? "",
      email: json['email']?? "",
      url_foto: json['url_foto']?? "",
      descricao: json['descricao']?? "",
      valor: json['valor']?? "",
      valor_frete: json['valor_frete']?? "",
      valor_total: json['valor_total']?? "",
      status_pagamento: json['status_pagamento']?? "",
      nome_status_pedido: json['nome_status_pedido']?? "",
      id_usuario: json['id_usuario']?? 0,
      nome_usuario: json['nome_usuario']?? "",
      email_usuario: json['email_usuario']?? "",
      documento_usuario: json['documento_usuario']?? "",
      tipo_pagamento: json['tipo_pagamento']?? 0,
      url_pagamento: json['url_pagamento']?? "",
      qrcode_pagamento: json['qrcode_pagamento']?? "",
      valor_pagamento: json['valor_pagamento']?? "",
      data_pagamento: json['data_pagamento']?? "",
      qrcode: json['qrcode']?? "",
      qrcode_64: json['qrcode_64']?? "",
      cod_barras: json['cod_barras']?? "",
      status: json['status']?? "",
      msg: json['msg']?? "",
      id: json['id']?? 0,
      rows: json['rows']?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'url_foto': url_foto,
      'descricao': descricao,
      'valor': valor,
      'valor_frete': valor_frete,
      'valor_total': valor_total,
      'status_pagamento': status_pagamento,
      'nome_status_pedido': nome_status_pedido,
      'status': status,
      'msg': msg,
      'id': id,
      'rows': rows,
    };
  }
}