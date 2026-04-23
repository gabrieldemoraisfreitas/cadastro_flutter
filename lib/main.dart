import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Garante que os plugins Flutter estejam inicializados antes de chamar runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Lê o token salvo na memória permanente
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('meu_token_seguro');

  runApp(MyApp(estaLogado: token != null));
}

class MyApp extends StatelessWidget {
  final bool estaLogado;
  const MyApp({super.key, required this.estaLogado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sessão Persistente',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Se estiver logado, vai direto para Home; senão, para Login
      home: estaLogado ? const HomeScreen() : const LoginScreen(),
    );
  }
}