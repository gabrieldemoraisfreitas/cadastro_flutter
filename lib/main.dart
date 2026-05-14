import 'package:flutter/material.dart';

import 'screens/usuarios_screen.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  static const Color laranjaPrincipal = Color(0xFFFF6B1A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CargaLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: laranjaPrincipal,
          primary: laranjaPrincipal,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
      ),
      home: const UsuariosScreen(),
    );
  }
}