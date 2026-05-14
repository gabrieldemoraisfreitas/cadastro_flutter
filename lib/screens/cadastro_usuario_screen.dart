import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';

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

  final List<String> _tiposServico = const [
    'Carga e descarga',
    'Entrega rápida',
    'Cliente recorrente',
    'Contato novo',
    'Atendimento comercial',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
    });

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
      final usuarioCriado = await _apiService.criarUsuario(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente cadastrado com sucesso'),
        ),
      );

      Navigator.pop(context, usuarioCriado);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar cliente: $erro'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  String? _validarObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const laranja = Color(0xFFFF6B1A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo cliente'),
        backgroundColor: laranja,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campoTexto(
                controller: _nomeController,
                label: 'Nome do cliente',
                icon: Icons.person_outline,
                validator: (value) => _validarObrigatorio(value, 'o nome'),
              ),
              const SizedBox(height: 14),
              _campoTexto(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }

                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              _campoTexto(
                controller: _cidadeController,
                label: 'Cidade',
                icon: Icons.location_on_outlined,
                validator: (value) => _validarObrigatorio(value, 'a cidade'),
              ),
              const SizedBox(height: 14),
              _campoTexto(
                controller: _telefoneController,
                label: 'Telefone / WhatsApp',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => _validarObrigatorio(value, 'o telefone'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _tipoServicoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de serviço',
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(),
                ),
                items: _tiposServico.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: _salvando
                    ? null
                    : (value) {
                        setState(() {
                          _tipoServicoSelecionado = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione o tipo de serviço';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _observacoesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: laranja,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_salvando,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}