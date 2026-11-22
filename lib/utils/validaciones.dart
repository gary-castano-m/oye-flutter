/// Reglas de validación, las mismas del backend y del Corte 3.
/// Cada función recibe el texto del campo y devuelve el mensaje de error,
/// o null si está bien. Es justo lo que espera el `validator` de un TextFormField.
class Validaciones {
  Validaciones._();

  static const int largoMinimoPassword = 8;

  static final RegExp _patronEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _patronUsername = RegExp(r'^[A-Za-z0-9._-]{3,30}$');

  static String? obligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio.';
    return null;
  }

  static String? email(String? valor) {
    if (!_patronEmail.hasMatch((valor ?? '').trim())) return 'Escribe un correo válido.';
    return null;
  }

  static String? username(String? valor) {
    if (!_patronUsername.hasMatch((valor ?? '').trim())) {
      return 'Entre 3 y 30 caracteres: letras, números, punto, guion o guion bajo.';
    }
    return null;
  }

  static String? nombre(String? valor) {
    if ((valor ?? '').trim().length < 3) return 'El nombre debe tener al menos 3 caracteres.';
    return null;
  }

  /// La contraseña no se recorta: los espacios cuentan.
  static String? password(String? valor) {
    if ((valor ?? '').length < largoMinimoPassword) {
      return 'La contraseña debe tener al menos $largoMinimoPassword caracteres.';
    }
    return null;
  }
}
