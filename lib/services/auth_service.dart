import '../models/usuario.dart';
import 'api_client.dart';

/// Peticiones de autenticación (equivale al AuthRepository del Corte 3).
/// En la Fase 2 se agregan login, registro y recuperar contraseña.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Despierta Render con una petición liviana.
  Future<void> despertar() => _api.despertar();

  /// Verifica que el token guardado siga siendo válido y trae los datos actualizados.
  Future<Usuario> miPerfil() async {
    final json = await _api.get('api/users/me');
    return Usuario.fromJson(json as Map<String, dynamic>);
  }
}
