import '../models/usuario.dart';

/// Traduce los valores de la API a textos en español para la pantalla
/// (equivale a Etiquetas.java del Corte 3).
class Etiquetas {
  Etiquetas._();

  /// Valores que acepta la API, en el orden en que aparecen en las listas desplegables.
  static const List<String> roles = [Usuario.rolAdmin, Usuario.rolReviewer, Usuario.rolMember];
  static const List<String> estados = ['ACTIVE', 'INACTIVE', 'PENDING', 'BLOCKED'];

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

  static String estado(String estado) {
    switch (estado) {
      case 'ACTIVE':
        return 'Activo';
      case 'INACTIVE':
        return 'Inactivo';
      case 'PENDING':
        return 'Pendiente';
      case 'BLOCKED':
        return 'Bloqueado';
      default:
        return estado;
    }
  }
}
