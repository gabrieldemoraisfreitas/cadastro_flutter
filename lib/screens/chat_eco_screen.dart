import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_colors.dart';

class Mensagem {
  const Mensagem({
    required this.texto,
    required this.origem,
    required this.horario,
  });

  final String texto;
  final String origem;
  final DateTime horario;
}

class ChatEcoPage extends StatefulWidget {
  const ChatEcoPage({super.key});

  @override
  State<ChatEcoPage> createState() => _ChatEcoPageState();
}

class _ChatEcoPageState extends State<ChatEcoPage> {
  final TextEditingController _mensagemController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(
    text: 'wss://echo.websocket.events',
  );
  final StreamController<List<Mensagem>> _mensagensController =
      StreamController<List<Mensagem>>.broadcast();

  final List<Mensagem> _mensagens = [];
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;

  bool _conectado = false;
  bool _conectando = false;
  String _status = 'Desconectado';

  @override
  void initState() {
    super.initState();
    _emitirMensagens();
  }

  Future<void> _conectar() async {
    if (_conectando || _conectado) return;

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _atualizarStatus('Informe uma URL WebSocket.');
      return;
    }

    setState(() {
      _conectando = true;
      _status = 'Conectando...';
    });

    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'ws' && uri.scheme != 'wss') {
        throw const FormatException();
      }

      final channel = WebSocketChannel.connect(uri);

      await channel.ready.timeout(const Duration(seconds: 8));
      if (!mounted) return;

      _channel = channel;
      _socketSubscription = channel.stream.listen(
        (event) {
          _adicionarMensagem(
            texto: event.toString(),
            origem: 'Servidor',
          );
        },
        onError: (error) {
          _atualizarStatus('Erro na conexão: $error');
          _marcarComoDesconectado();
        },
        onDone: () {
          _atualizarStatus('Conexão encerrada pelo servidor.');
          _marcarComoDesconectado();
        },
      );

      setState(() {
        _conectado = true;
        _conectando = false;
        _status = 'Conectado em $url';
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _conectando = false;
        _status = 'URL inválida. Use ws:// ou wss://.';
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _conectando = false;
        _status = 'Tempo esgotado ao conectar.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _conectando = false;
        _status = 'Não foi possível conectar: $error';
      });
    }
  }

  void _enviarMensagem() {
    final texto = _mensagemController.text.trim();

    if (!_conectado || _channel == null) {
      _atualizarStatus('Conecte antes de enviar.');
      return;
    }

    if (texto.isEmpty) {
      _atualizarStatus('Digite uma mensagem.');
      return;
    }

    _channel!.sink.add(texto);
    _adicionarMensagem(texto: texto, origem: 'Você');
    _mensagemController.clear();
  }

  Future<void> _desconectar() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;

    await _channel?.sink.close(status.goingAway);
    _channel = null;

    _marcarComoDesconectado(mensagem: 'Desconectado pelo usuário.');
  }

  void _adicionarMensagem({
    required String texto,
    required String origem,
  }) {
    _mensagens.add(
      Mensagem(
        texto: texto,
        origem: origem,
        horario: DateTime.now(),
      ),
    );
    _emitirMensagens();
  }

  void _emitirMensagens() {
    if (!_mensagensController.isClosed) {
      _mensagensController.add(List<Mensagem>.unmodifiable(_mensagens));
    }
  }

  void _atualizarStatus(String mensagem) {
    if (!mounted) return;

    setState(() {
      _status = mensagem;
    });
  }

  void _marcarComoDesconectado({String? mensagem}) {
    if (!mounted) return;

    setState(() {
      _conectado = false;
      _conectando = false;
      if (mensagem != null) {
        _status = mensagem;
      }
    });
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _urlController.dispose();
    _socketSubscription?.cancel();
    _channel?.sink.close(status.goingAway);
    _mensagensController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Chat de Eco'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _conectado ? _desconectar : _conectar,
            icon: Icon(_conectado ? Icons.link_off : Icons.link),
            tooltip: _conectado ? 'Desconectar' : 'Conectar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                enabled: !_conectado && !_conectando,
                decoration: const InputDecoration(
                  labelText: 'URL WebSocket',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _StatusConexao(
                conectado: _conectado,
                conectando: _conectando,
                status: _status,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Mensagem>>(
                  stream: _mensagensController.stream,
                  initialData: const [],
                  builder: (context, snapshot) {
                    final mensagens = snapshot.data ?? const <Mensagem>[];

                    if (mensagens.isEmpty) {
                      return const Center(
                        child: Text('Conecte e envie uma mensagem.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final mensagem = mensagens[index];
                        final enviadaPorMim = mensagem.origem == 'Você';

                        return Align(
                          alignment: enviadaPorMim
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Card(
                            color: enviadaPorMim
                                ? AppColors.laranja.withOpacity(0.16)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mensagem.origem,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(mensagem.texto),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatarHorario(mensagem.horario),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensagemController,
                      enabled: _conectado,
                      decoration: const InputDecoration(
                        labelText: 'Mensagem',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _enviarMensagem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _conectado ? _enviarMensagem : null,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarHorario(DateTime horario) {
    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');
    final segundo = horario.second.toString().padLeft(2, '0');
    return '$hora:$minuto:$segundo';
  }
}

class _StatusConexao extends StatelessWidget {
  const _StatusConexao({
    required this.conectado,
    required this.conectando,
    required this.status,
  });

  final bool conectado;
  final bool conectando;
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color cor;
    final IconData icone;

    if (conectando) {
      cor = Colors.orange;
      icone = Icons.sync;
    } else if (conectado) {
      cor = Colors.green;
      icone = Icons.check_circle;
    } else {
      cor = Colors.red;
      icone = Icons.cancel;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        border: Border.all(color: cor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 8),
          Expanded(child: Text(status)),
        ],
      ),
    );
  }
}
