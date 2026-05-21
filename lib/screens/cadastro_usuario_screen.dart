import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _tipoServicoSelecionado;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  String? _validarObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) return 'Informe $campo';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final usuario = Usuario(
      id: 0,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cidade: _cidadeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      tipoServico: _tipoServicoSelecionado!,
      observacoes: _observacoesController.text.trim().isEmpty
          ? 'Cliente cadastrado manualmente no CargaLink.'
          : _observacoesController.text.trim(),
    );

    try {
      final criado = await _apiService.criarUsuario(usuario);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente cadastrado com sucesso')),
      );
      Navigator.pop(context, criado);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar cliente: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo cliente'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CampoTexto(
                controller: _nomeController,
                label: 'Nome do cliente',
                icon: Icons.person_outline,
                enabled: !_salvando,
                validator: (v) => _validarObrigatorio(v, 'o nome'),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !_salvando,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CampoTexto(
                controller: _cidadeController,
                label: 'Cidade',
                icon: Icons.location_on_outlined,
                enabled: !_salvando,
                validator: (v) => _validarObrigatorio(v, 'a cidade'),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                controller: _telefoneController,
                label: 'Telefone / WhatsApp',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: !_salvando,
                validator: (v) => _validarObrigatorio(v, 'o telefone'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _tipoServicoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de serviço',
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.tiposServico
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (value) => setState(() => _tipoServicoSelecionado = value),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Selecione o tipo de serviço' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _observacoesController,
                maxLines: 4,
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              BotaoPrimario(
                label: 'Salvar cliente',
                icon: Icons.save_outlined,
                onPressed: _salvar,
                carregando: _salvando,
                labelCarregando: 'Salvando...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
