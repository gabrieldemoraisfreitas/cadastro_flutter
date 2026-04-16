import 'package:flutter/material.dart';

class PatosScreen extends StatelessWidget {
  const PatosScreen({super.key});

  final List<String> patos = const [
    'Zorglax o Devastador',
    'Quacktron 9000',
    'Patozila Cósmico',
    'Lorde Bico das Trevas',
    'Xablau Intergaláctico',
    'Capitão Pato Nebuloso',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Pato Alienígena 🛸'),
      ),
      body: ListView.builder(
        itemCount: patos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(patos[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Você escolheu: ${patos[index]}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}