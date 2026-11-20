/// Un gasto tal como lo devuelve la API: los campos del ejercicio 6.
class Gasto {
  final String id;
  final String fecha; // formato yyyy-MM-dd
  final double valorTotalSinIva;
  final double ivaTotal;
  final double valorTotalConIva;
  final String usuarioId;
  final String nombreUsuario;
  final String lugar;
  final String descripcion;

  const Gasto({
    required this.id,
    required this.fecha,
    required this.valorTotalSinIva,
    required this.ivaTotal,
    required this.valorTotalConIva,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.lugar,
    required this.descripcion,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      valorTotalSinIva: aDouble(json['valorTotalSinIva']),
      ivaTotal: aDouble(json['ivaTotal']),
      valorTotalConIva: aDouble(json['valorTotalConIva']),
      usuarioId: json['usuarioId']?.toString() ?? '',
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      lugar: json['lugar']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }
}

/// La API manda los valores como número (BigDecimal en Java).
/// Esto los convierte a double aunque lleguen como texto o vacíos.
double aDouble(Object? valor) {
  if (valor is num) return valor.toDouble();
  if (valor is String) return double.tryParse(valor) ?? 0;
  return 0;
}
