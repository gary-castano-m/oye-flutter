/// Error de una petición, con un mensaje en español listo para mostrar en pantalla.
/// Cumple el papel de onError(String mensaje) del Corte 3.
class ApiException implements Exception {
  final String mensaje;
  final int? codigo; // código HTTP, si el servidor alcanzó a responder

  const ApiException(this.mensaje, {this.codigo});

  @override
  String toString() => mensaje;
}
