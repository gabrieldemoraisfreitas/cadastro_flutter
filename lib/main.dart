import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/usuarios_screen.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CargaLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.laranja,
          primary: AppColors.laranja,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.fundo,
      ),
      home: const UsuariosScreen(),
    );
  }
}
