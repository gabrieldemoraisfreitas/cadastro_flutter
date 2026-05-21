import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Campo de texto padronizado com ícone
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

// Card de seção com título e filhos (usado em DetalhesClienteScreen)
class SecaoCard extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const SecaoCard({
    super.key,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// Linha de informação com ícone, título e valor (usado em DetalhesClienteScreen)
class LinhaInfo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const LinhaInfo({
    super.key,
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Card informativo com título e texto (usado em SobreScreen)
class CardInfo extends StatelessWidget {
  final String titulo;
  final String texto;

  const CardInfo({
    super.key,
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

// Botão primário full-width com loading opcional
class BotaoPrimario extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool carregando;
  final String labelCarregando;
  final Color? cor;

  const BotaoPrimario({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.carregando = false,
    this.labelCarregando = 'Aguarde...',
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: carregando ? null : onPressed,
        icon: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(carregando ? labelCarregando : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: cor ?? AppColors.laranja,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
