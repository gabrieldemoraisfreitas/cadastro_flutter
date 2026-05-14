import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const laranja = Color(0xFFFF6B1A);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: laranja,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CargaLink ⚡',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Mini CRM de serviços com Flutter e API REST.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _CardInfo(
            titulo: 'Problema que o app resolve',
            texto:
                'O CargaLink ajuda trabalhadores autônomos e prestadores de serviço a organizar clientes, cidades atendidas, contatos e tipos de serviço.',
          ),
          _CardInfo(
            titulo: 'O que foi usado da aula',
            texto:
                'GET /users para listar clientes, POST /users para cadastrar e DELETE /users/{id} para remover. Também há toJson, SnackBar, AlertDialog, loading e tratamento de erro.',
          ),
          _CardInfo(
            titulo: 'Sobre a API',
            texto:
                'O JSONPlaceholder é uma API de testes. Ela retorna sucesso no cadastro e na exclusão, mas não salva os dados de verdade.',
          ),
        ],
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String titulo;
  final String texto;

  const _CardInfo({
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}