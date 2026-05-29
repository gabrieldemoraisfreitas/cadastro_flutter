import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

class PerfilComFotoPage extends StatefulWidget {
  const PerfilComFotoPage({super.key});

  @override
  State<PerfilComFotoPage> createState() => _PerfilComFotoPageState();
}

class _PerfilComFotoPageState extends State<PerfilComFotoPage> {
  XFile? _imagemSelecionada;
  bool _carregando = false;
  String _status = 'Nenhuma imagem selecionada.';

  final ImagePicker _picker = ImagePicker();

  Future<void> _selecionarImagem(ImageSource origem) async {
    setState(() {
      _carregando = true;
      _status = origem == ImageSource.gallery
          ? 'Abrindo galeria...'
          : 'Abrindo câmera...';
    });

    try {
      final imagem = await _picker.pickImage(
        source: origem,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (!mounted) return;

      if (imagem == null) {
        setState(() {
          _status = 'Ação cancelada. Nenhuma imagem foi selecionada.';
        });
        return;
      }

      setState(() {
        _imagemSelecionada = imagem;
        _status = origem == ImageSource.gallery
            ? 'Imagem selecionada da galeria.'
            : 'Foto capturada com a câmera.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem carregada com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _status = 'Não foi possível carregar a imagem.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $erro')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Perfil com Foto'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PreviewImagem(imagem: _imagemSelecionada),
              const SizedBox(height: 18),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 18),
              if (_carregando)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.laranja),
                )
              else
                _BotoesImagem(
                  onGaleria: () => _selecionarImagem(ImageSource.gallery),
                  onCamera: () => _selecionarImagem(ImageSource.camera),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewImagem extends StatelessWidget {
  const _PreviewImagem({required this.imagem});

  final XFile? imagem;

  @override
  Widget build(BuildContext context) {
    if (imagem == null) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Nenhuma imagem para visualizar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(imagem!.path),
        height: 260,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BotoesImagem extends StatelessWidget {
  const _BotoesImagem({
    required this.onGaleria,
    required this.onCamera,
  });

  final VoidCallback onGaleria;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGaleria,
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeria'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onCamera,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Câmera'),
          ),
        ),
      ],
    );
  }
}
