import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response.dart';
import '../models/usuario.dart';

/// Guarda la sesión en el celular con shared_preferences.
/// Es el SessionManager del Corte 3 (y el TinyDB de Kodular), con las mismas etiquetas.
class SessionService {
  SessionService._();

  /// Una sola instancia para toda la app (patrón Singleton).
  static final SessionService instance = SessionService._();

  static const String _claveToken = 'sesion_token';
  static const String _claveUsuario = 'sesion_usuario';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Se llama justo después de un login exitoso.
  Future<void> guardarSesion(LoginResponse login) async {
    final prefs = await _prefs;
    await prefs.setString(_claveToken, login.accessToken);
    await prefs.setString(_claveUsuario, jsonEncode(login.user.toJson()));
  }

  /// Se llama cuando el usuario cambia sus datos en Mi perfil.
  Future<void> actualizarUsuario(Usuario usuario) async {
    final prefs = await _prefs;
    await prefs.setString(_claveUsuario, jsonEncode(usuario.toJson()));
  }

  Future<String?> leerToken() async {
    final prefs = await _prefs;
    return prefs.getString(_claveToken);
  }

  Future<Usuario?> leerUsuario() async {
    final prefs = await _prefs;
    final json = prefs.getString(_claveUsuario);
    if (json == null) return null;
    return Usuario.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<bool> haySesion() async {
    return await leerToken() != null && await leerUsuario() != null;
  }

  Future<void> cerrarSesion() async {
    final prefs = await _prefs;
    await prefs.remove(_claveToken);
    await prefs.remove(_claveUsuario);
  }
}
