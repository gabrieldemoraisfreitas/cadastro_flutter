import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';
import 'cadastro_usuario_screen.dart';
import 'detalhes_cliente_screen.dart';
import 'servico.dart';
import 'sobre_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  static const Color laranja = Color(0xFFFF6B1A);
  static const Color fundo = Color(0xFFF7F7F2);

  final _apiService = ApiService();
  final _buscaController = TextEditingController();

  List<Usuario> _usuarios = [];
  bool _carregando = true;
  String? _erro;
  int _abaSelecionada = 0;

  @override
  void initState() {
    super.initState();
    _buscarUsuarios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Usuario> get _usuariosFiltrados {
    final busca = _buscaController.text.trim().toLowerCase();

    if (busca.isEmpty) {
      return _usuarios;
    }

    return _usuarios.where((usuario) {
      return usuario.nome.toLowerCase().contains(busca) ||
          usuario.cidade.toLowerCase().contains(busca);
    }).toList();
  }

  int get _totalCidades {
    return _usuarios.map((usuario) => usuario.cidade).toSet().length;
  }

  Future<void> _buscarUsuarios() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuarios = await _apiService.buscarUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar os clientes.\n\nErro: $erro';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroUsuarioScreen(),
      ),
    );

    if (resultado != null) {
      setState(() {
        _usuarios.insert(0, resultado);
      });
    }
  }

  Future<void> _abrirDetalhes(Usuario usuario) async {
    final removido = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesClienteScreen(usuario: usuario),
      ),
    );

    if (removido == true) {
      setState(() {
        _usuarios.removeWhere((item) => item.id == usuario.id);
      });
    }
  }

  Future<void> _confirmarExclusao(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover cliente'),
          content: Text(
            'Deseja remover ${usuario.nome} da sua lista de clientes?',
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

    try {
      await _apiService.deletarUsuario(usuario.id);

      if (!mounted) return;

      setState(() {
        _usuarios.removeWhere((item) => item.id == usuario.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente removido com sucesso'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover cliente: $erro'),
        ),
      );
    }
  }

  void _trocarAba(int index) {
    if (index == 2) {
      _abrirCadastro();
      return;
    }

    setState(() {
      _abaSelecionada = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: IndexedStack(
        index: _abaSelecionada,
        children: [
          _buildTelaClientes(),
          const ServicosScreen(),
          const SizedBox.shrink(),
          const SobreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaSelecionada,
        onDestinationSelected: _trocarAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Serviços',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }

  Widget _buildTelaClientes() {
    return SafeArea(
      child: Column(
        children: [
          _buildCabecalho(),
          Expanded(
            child: _buildConteudoClientes(),
          ),
        ],
      ),
    );
  }

  Widget _buildCabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: laranja,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CargaLink ⚡',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Clientes de serviço',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _buscarUsuarios,
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            tooltip: 'Recarregar',
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoClientes() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: laranja),
            SizedBox(height: 16),
            Text('Carregando clientes...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 58,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _buscarUsuarios,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _buildPainelResumo(),
        const SizedBox(height: 12),
        _buildCampoBusca(),
        const SizedBox(height: 12),
        if (_usuariosFiltrados.isEmpty)
          _buildListaVazia()
        else
          ..._usuariosFiltrados.map(_buildCardCliente),
      ],
    );
  }

  Widget _buildPainelResumo() {
    return Row(
      children: [
        Expanded(
          child: _cardResumo(
            valor: _usuarios.length.toString(),
            titulo: 'Clientes',
            icon: Icons.groups_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _cardResumo(
            valor: '5',
            titulo: 'Serviços ativos',
            icon: Icons.work_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _cardResumo(
            valor: _totalCidades.toString(),
            titulo: 'Cidades',
            icon: Icons.location_city_outlined,
          ),
        ),
      ],
    );
  }

  Widget _cardResumo({
    required String valor,
    required String titulo,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEE8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoBusca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Buscar por nome ou cidade...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildListaVazia() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 44, color: Colors.grey),
          SizedBox(height: 10),
          Text('Nenhum cliente encontrado.'),
        ],
      ),
    );
  }

  Widget _buildCardCliente(Usuario usuario) {
    final corAvatar = _corAvatar(usuario.id);
    final corTag = _corTag(usuario.tipoServico);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _abrirDetalhes(usuario),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: corAvatar.withOpacity(0.15),
              child: Text(
                _iniciais(usuario.nome),
                style: TextStyle(
                  color: corAvatar,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${usuario.cidade} · ${usuario.email}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corTag.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      usuario.tipoServico,
                      style: TextStyle(
                        color: corTag,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _confirmarExclusao(usuario),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              tooltip: 'Remover',
            ),
            IconButton(
              onPressed: () => _abrirDetalhes(usuario),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Detalhes',
            ),
          ],
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');

    if (partes.isEmpty || partes.first.isEmpty) {
      return '?';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color _corAvatar(int id) {
    final cores = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.deepPurple,
      Colors.pink,
      Colors.teal,
    ];

    return cores[id % cores.length];
  }

  Color _corTag(String tipo) {
    switch (tipo) {
      case 'Carga e descarga':
        return Colors.brown;
      case 'Entrega rápida':
        return Colors.blue;
      case 'Cliente recorrente':
        return Colors.green;
      case 'Contato novo':
        return Colors.grey;
      case 'Atendimento comercial':
        return Colors.deepPurple;
      default:
        return laranja;
    }
  }
}