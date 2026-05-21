import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/widgets.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.laranja,
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
                      fontWeight: FontWeight.bold),
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
          const CardInfo(
            titulo: 'Problema que o app resolve',
            texto:
                'O CargaLink ajuda trabalhadores autônomos e prestadores de serviço a organizar clientes, cidades atendidas, contatos e tipos de serviço.',
          ),
          const CardInfo(
            titulo: 'O que foi usado da aula',
            texto:
                'GET /users para listar clientes, POST /users para cadastrar e DELETE /users/{id} para remover. Também há toJson, SnackBar, AlertDialog, loading e tratamento de erro.',
          ),
          const CardInfo(
            titulo: 'Sobre a API',
            texto:
                'O JSONPlaceholder é uma API de testes. Ela retorna sucesso no cadastro e na exclusão, mas não salva os dados de verdade.',
          ),
        ],
      ),
    );
  }
}
