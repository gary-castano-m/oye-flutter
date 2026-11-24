/// Formatos para mostrar dinero y fechas como se leen en Colombia
/// (equivale a Formato.java del Corte 3).
class Formato {
  Formato._();

  /// 11900 → "$ 11.900"   ·   1234.5 → "$ 1.234,5"   ·   -500 → "-$ 500"
  static String dinero(double valor) {
    final negativo = valor < 0;
    final centavos = (valor.abs() * 100).round();
    final enteros = centavos ~/ 100;
    final decimales = centavos % 100;

    // Separador de miles con punto: 1234567 → 1.234.567
    final digitos = enteros.toString();
    final conPuntos = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) conPuntos.write('.');
      conPuntos.write(digitos[i]);
    }

    var texto = '\$ $conPuntos';
    if (decimales > 0) {
      // Como "#,##0.##" en Java: hasta dos decimales, sin ceros sobrantes.
      var parteDecimal = decimales.toString().padLeft(2, '0');
      if (parteDecimal.endsWith('0')) parteDecimal = parteDecimal.substring(0, 1);
      texto += ',$parteDecimal';
    }
    return negativo ? '-$texto' : texto;
  }

  /// "2026-11-03" (como lo envía la API) → "03/11/2026"
  static String fecha(String iso) {
    if (iso.length < 10) return '';
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
  }

  /// Fecha del celular → "2026-11-03", el formato que recibe la API.
  static String fechaIso(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.year.toString().padLeft(4, '0')}-${dos(fecha.month)}-${dos(fecha.day)}';
  }

  /// "2026-11-03" → DateTime. Si el texto no es una fecha, devuelve null.
  static DateTime? leerFechaIso(String iso) => DateTime.tryParse(iso);

  /// Acepta "10000", "10000.50" o "10000,50". Devuelve null si no es un número.
  static double? leerValor(String texto) {
    final limpio = texto.trim().replaceAll(',', '.');
    if (limpio.isEmpty) return null;
    return double.tryParse(limpio);
  }
}
