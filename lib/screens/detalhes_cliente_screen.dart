import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
 
class DetalhesClienteScreen extends StatefulWidget {
  final Usuario usuario;
 
  const DetalhesClienteScreen({super.key, required this.usuario});
 
  @override
  State<DetalhesClienteScreen> createState() => _DetalhesClienteScreenState();
}
 
class _DetalhesClienteScreenState extends State<DetalhesClienteScreen> {
  final _apiService = ApiService();
  bool _removendo = false;
 
  String get _iniciais {
    final partes = widget.usuario.nome.trim().split(' ');
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
 
  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }
 
  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover cliente'),
        content: Text(
            'Deseja remover ${widget.usuario.nome} da sua lista de clientes?'),
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
      ),
    );
 
    if (confirmar != true) return;
 
    setState(() => _removendo = true);
 
    try {
      await _apiService.deletarUsuario(widget.usuario.id);
      if (!mounted) return;
      _mostrarSnack('Cliente removido com sucesso');
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      _mostrarSnack('Erro ao remover cliente: $erro');
    } finally {
      if (mounted) setState(() => _removendo = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final historico = [
      'Contato inicial registrado',
      'Serviço solicitado: ${widget.usuario.tipoServico}',
      'Aguardando próxima confirmação',
    ];
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do cliente'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _CartaoIdentidade(),
            const SizedBox(height: 16),
            SecaoCard(
              titulo: 'Dados de contato',
              children: [
                LinhaInfo(icon: Icons.email_outlined, titulo: 'E-mail', valor: widget.usuario.email),
                LinhaInfo(icon: Icons.phone_outlined, titulo: 'Telefone / WhatsApp', valor: widget.usuario.telefone),
                LinhaInfo(icon: Icons.location_on_outlined, titulo: 'Cidade', valor: widget.usuario.cidade),
              ],
            ),
            const SizedBox(height: 16),
            SecaoCard(
              titulo: 'Observações',
              children: [
                Text(widget.usuario.observacoes,
                    style: const TextStyle(height: 1.4)),
              ],
            ),
            const SizedBox(height: 16),
            SecaoCard(
              titulo: 'Histórico de serviços',
              children: historico
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.laranja),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarSnack(
                        'Abrindo contato de ${widget.usuario.nome}...'),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Contato'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarSnack(
                        'Novo serviço para ${widget.usuario.nome} registrado localmente.'),
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
 
  Widget _CartaoIdentidade() {
    return Container(
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
            backgroundColor: AppColors.laranja.withOpacity(0.14),
            child: Text(
              _iniciais,
              style: const TextStyle(
                color: AppColors.laranja,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.usuario.nome,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(widget.usuario.cidade,
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          Chip(
            label: Text(widget.usuario.tipoServico),
            backgroundColor: AppColors.laranja.withOpacity(0.12),
            labelStyle: const TextStyle(
              color: AppColors.laranja,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}