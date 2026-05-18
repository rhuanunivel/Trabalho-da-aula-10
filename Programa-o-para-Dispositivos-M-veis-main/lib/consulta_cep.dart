import 'dart:convert';

import 'package:http/http.dart' as http;

import 'endereco.dart';

class ConsultaCep {
  static Future<Endereco> fetchCep(String cep) async {
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cep/json/'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['erro'] == true) {
        throw Exception('CEP não encontrado');
      }

      return Endereco.fromJson(json);
    } else {
      throw Exception('Erro ao buscar CEP');
    }
  }
}
