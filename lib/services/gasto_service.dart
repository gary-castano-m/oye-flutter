import '../models/gasto.dart';
import 'api_client.dart';

/// CRUD de la tabla Gastos (equivale al GastoRepository del Corte 3).
/// El token lo pone ApiClient. El backend decide qué gastos ve cada rol:
/// MEMBER solo los suyos; ADMIN y REVIEWER los de todos.
class GastoService {
  final ApiClient _api = ApiClient.instance;

  /// GET /api/gastos
  Future<List<Gasto>> listar() async {
    final json = await _api.get('api/gastos') as List<dynamic>;
    return json.map((g) => Gasto.fromJson(g as Map<String, dynamic>)).toList();
  }

  /// GET /api/gastos/{id}
  Future<Gasto> consultar(String id) async {
    final json = await _api.get('api/gastos/$id');
    return Gasto.fromJson(json as Map<String, dynamic>);
  }

  /// POST /api/gastos. El IVA y el total los calcula el servidor.
  Future<Gasto> registrar({
    required String fecha,
    required double valorSinIva,
    required String lugar,
    required String descripcion,
  }) async {
    final json = await _api.post('api/gastos', body: _cuerpo(fecha, valorSinIva, lugar, descripcion));
    return Gasto.fromJson(json as Map<String, dynamic>);
  }

  /// PUT /api/gastos/{id}
  Future<Gasto> actualizar(
    String id, {
    required String fecha,
    required double valorSinIva,
    required String lugar,
    required String descripcion,
  }) async {
    final json = await _api.put('api/gastos/$id', body: _cuerpo(fecha, valorSinIva, lugar, descripcion));
    return Gasto.fromJson(json as Map<String, dynamic>);
  }

  /// DELETE /api/gastos/{id}
  Future<void> eliminar(String id) => _api.delete('api/gastos/$id');

  /// Mismos campos que GastoRequest del Corte 3.
  Map<String, dynamic> _cuerpo(String fecha, double valor, String lugar, String descripcion) => {
        'fecha': fecha,
        'valorTotalSinIva': valor,
        'lugar': lugar,
        'descripcion': descripcion,
      };
}
