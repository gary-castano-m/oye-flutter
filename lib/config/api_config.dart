/// Datos fijos de conexión con el backend del Corte 2 (el mismo del Corte 3).
class ApiConfig {
  ApiConfig._();

  /// Dirección del backend en Render. Debe terminar en "/".
  static const String baseUrl = 'https://oye-api-j5l4.onrender.com/';

  /// Render gratuito puede tardar hasta un minuto en despertar: 70 s, como en Kodular y Android.
  static const Duration timeout = Duration(seconds: 70);
}
