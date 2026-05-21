import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthService {
  // Simula uma chamada de API com delay de 2 segundos
  Future<String?> login(String email, String senha) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'aluno@etec.sp.gov.br' && senha == '123456') {
      return 'sucesso_token_123';
    }
    return null;
  }

  Future<void> salvarSessao(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.tokenKey);
  }
}
