import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Usuario>> buscarUsuarios() async {
    final uri = Uri.parse('$_baseUrl/users');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar clientes: ${response.statusCode}');
    }

    final listaJson = jsonDecode(response.body) as List<dynamic>;

    return listaJson
        .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> criarUsuario(Usuario usuario) async {
    final uri = Uri.parse('$_baseUrl/users');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode == 201) {
      return Usuario.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao cadastrar cliente: ${response.statusCode}');
  }

  Future<void> deletarUsuario(int id) async {
    final uri = Uri.parse('$_baseUrl/users/$id');

    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao remover cliente: ${response.statusCode}');
    }
  }
}