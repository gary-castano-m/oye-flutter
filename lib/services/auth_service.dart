import '../models/login_response.dart';
import '../models/usuario.dart';
import 'api_client.dart';

/// Peticiones de acceso (equivale al AuthRepository del Corte 3):
/// despertar el servidor, login, registro, recuperar la clave y verificar la sesión.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Despierta Render con una petición liviana.
  Future<void> despertar() => _api.despertar();

  /// POST /api/auth/login. "usuario" acepta el username o el correo.
  Future<LoginResponse> login(String usuario, String password) async {
    final json = await _api.post(
      'api/auth/login',
      body: {'usuario': usuario, 'password': password},
    );
    return LoginResponse.fromJson(json as Map<String, dynamic>);
  }

  /// POST /api/auth/register. La cuenta queda como MEMBER y activa.
  Future<Usuario> registrar({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      'api/auth/register',
      body: {'username': username, 'name': name, 'email': email, 'password': password},
    );
    return Usuario.fromJson(json as Map<String, dynamic>);
  }

  /// POST /api/auth/forgot-password. El backend envía una contraseña temporal con Brevo.
  /// Responde igual exista o no el correo, para no revelar quién está registrado.
  Future<void> recuperarClave(String email) async {
    await _api.post('api/auth/forgot-password', body: {'email': email});
  }

  /// GET /api/users/me: si responde, el token guardado sigue siendo válido.
  Future<Usuario> miPerfil() async {
    final json = await _api.get('api/users/me');
    return Usuario.fromJson(json as Map<String, dynamic>);
  }
}
