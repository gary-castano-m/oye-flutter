import '../models/usuario.dart';

/// Traduce los valores de la API a textos en español para la pantalla.
class Etiquetas {
  Etiquetas._();

  static String rol(String rol) {
    switch (rol) {
      case Usuario.rolAdmin:
        return 'Administrador';
      case Usuario.rolReviewer:
        return 'Revisor';
      case Usuario.rolMember:
        return 'Miembro';
      default:
        return rol;
    }
  }
}
