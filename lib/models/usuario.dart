import '../constants/app_constants.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  final String cidade;
  final String telefone;
  final String tipoServico;
  final String observacoes;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cidade,
    required this.telefone,
    required this.tipoServico,
    required this.observacoes,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final endereco = json['address'];
    final id = json['id'] is int ? json['id'] as int : 0;

    return Usuario(
      id: id,
      nome: json['name']?.toString() ?? 'Cliente sem nome',
      email: json['email']?.toString() ?? 'sem-email@exemplo.com',
      cidade: endereco is Map<String, dynamic>
          ? endereco['city']?.toString() ?? 'Cidade não informada'
          : 'Cidade não informada',
      telefone: json['phone']?.toString() ?? _telefonePadrao(id),
      tipoServico: json['tipoServico']?.toString() ?? _tipoServicoPadrao(id),
      observacoes: json['observacoes']?.toString() ??
          'Cliente importado da API de testes JSONPlaceholder.',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': nome,
        'email': email,
        'address': {'city': cidade},
        'phone': telefone,
        'tipoServico': tipoServico,
        'observacoes': observacoes,
      };

  static String _telefonePadrao(int id) {
    return '(19) 99999-${id.toString().padLeft(4, '0')}';
  }

  static String _tipoServicoPadrao(int id) {
    return AppConstants.tiposServico[id % AppConstants.tiposServico.length];
  }
}
