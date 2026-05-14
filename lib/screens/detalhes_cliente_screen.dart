import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';

class DetalhesClienteScreen extends StatefulWidget {
  final Usuario usuario;

  const DetalhesClienteScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<DetalhesClienteScreen> createState() => _DetalhesClienteScreenState();
}

class _DetalhesClienteScreenState extends State<DetalhesClienteScreen> {
  final _apiService = ApiService();
  bool _removendo = false;

  String get _iniciais {
    final partes = widget.usuario.nome.trim().split(' ');

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }

  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover cliente'),
          content: Text(
            'Deseja remover ${widget.usuario.nome} da sua lista de clientes?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      _removendo = true;
    });

    try {
      await _apiService.deletarUsuario(widget.usuario.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente removido com sucesso'),
        ),
      );

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover cliente: $erro'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _removendo = false;
        });
      }
    }
  }

  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const laranja = Color(0xFFFF6B1A);

    final historico = [
      'Contato inicial registrado',
      'Serviço solicitado: ${widget.usuario.tipoServico}',
      'Aguardando próxima confirmação',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do cliente'),
        backgroundColor: laranja,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: laranja.withOpacity(0.14),
                    child: Text(
                      _iniciais,
                      style: const TextStyle(
                        color: laranja,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.usuario.nome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.usuario.cidade,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(widget.usuario.tipoServico),
                    backgroundColor: laranja.withOpacity(0.12),
                    labelStyle: const TextStyle(
                      color: laranja,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Dados de contato',
              children: [
                _linhaInfo(Icons.email_outlined, 'E-mail', widget.usuario.email),
                _linhaInfo(
                  Icons.phone_outlined,
                  'Telefone / WhatsApp',
                  widget.usuario.telefone,
                ),
                _linhaInfo(
                  Icons.location_on_outlined,
                  'Cidade',
                  widget.usuario.cidade,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Observações',
              children: [
                Text(
                  widget.usuario.observacoes,
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Histórico de serviços',
              children: historico.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: laranja),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarSnack(
                      'Abrindo contato de ${widget.usuario.nome}...',
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Contato'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarSnack(
                      'Novo serviço para ${widget.usuario.nome} registrado localmente.',
                    ),
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Serviço'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _removendo ? null : _confirmarRemocao,
                icon: _removendo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(_removendo ? 'Removendo...' : 'Remover cliente'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao({
    required String titulo,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _linhaInfo(IconData icon, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}