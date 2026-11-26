import '../models/usuario.dart';
import 'api_client.dart';

/// Mi perfil (/api/users/me) y CRUD de la tabla Usuario (solo ADMIN).
/// Equivale al UserRepository del Corte 3.
class UsuarioService {
  final ApiClient _api = ApiClient.instance;

  // ---------- Mi perfil: no lleva id, el usuario sale del token ----------

  /// GET /api/users/me
  Future<Usuario> miPerfil() async {
    final json = await _api.get('api/users/me');
    return Usuario.fromJson(json as Map<String, dynamic>);
  }

  /// PUT /api/users/me. Contraseña vacía = no se cambia.
  Future<Usuario> actualizarPerfil({
    required String username,
    required String name,
    required String email,
    String password = '',
  }) async {
    final json = await _api.put(
      'api/users/me',
      body: cuerpo(username: username, name: name, email: email, password: password),
    );
    return Usuario.fromJson(json as Map<String, dynamic>);
  }

  // ---------- CRUD (solo ADMIN) ----------

  /// GET /api/users
  Future<List<Usuario>> listar() async {
    final json = await _api.get('api/users') as List<dynamic>;
    return json.map((u) => Usuario.fromJson(u as Map<String, dynamic>)).toList();
  }

  /// POST /api/users. Un usuario creado por el ADMIN queda activo.
  Future<Usuario> crear({
    required String username,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final json = await _api.post(
      'api/users',
      body: cuerpo(username: username, name: name, email: email, password: password, role: role),
    );
    return Usuario.fromJson(json as Map<String, dynamic>);
  }

  /// PUT /api/users/{id}. Contraseña vacía = no se cambia.
  Future<Usuario> actualizar(
    String id, {
    required String username,
    required String name,
    required String email,
    required String role,
    required String status,
    String password = '',
  }) async {
    final json = await _api.put(
      'api/users/$id',
      body: cuerpo(
        username: username,
        name: name,
        email: email,
        password: password,
        role: role,
        status: status,
      ),
    );
    return Usuario.fromJson(json as Map<String, dynamic>);
  }

  /// DELETE /api/users/{id}
  Future<void> eliminar(String id) => _api.delete('api/users/$id');

  /// GET /api/users/reports — los dos reportes parametrizados de Usuario:
  /// por rol (ADMIN, REVIEWER o MEMBER) o por nombre (coincidencia parcial).
  /// El filtro que va en null no se envía.
  Future<List<Usuario>> reporte({String? rol, String? nombre}) async {
    final json = await _api.get('api/users/reports', query: {'role': rol, 'name': nombre})
        as List<dynamic>;
    return json.map((u) => Usuario.fromJson(u as Map<String, dynamic>)).toList();
  }

  /// Arma el JSON que se envía. Los campos vacíos no se incluyen,
  /// igual que Gson omitía los null en el Corte 3: así la contraseña no se cambia
  /// si se deja vacía. Es pública para poder probarla.
  static Map<String, dynamic> cuerpo({
    required String username,
    required String name,
    required String email,
    String password = '',
    String? role,
    String? status,
  }) {
    return {
      'username': username,
      'name': name,
      'email': email,
      if (password.isNotEmpty) 'password': password,
      'role': ?role,
      'status': ?status,
    };
  }
}
