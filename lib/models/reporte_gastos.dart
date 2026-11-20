import 'gasto.dart';

/// Respuesta de GET /api/gastos/reports: la lista filtrada y sus totales.
class ReporteGastos {
  final int cantidad;
  final double totalSinIva;
  final double totalIva;
  final double totalConIva;
  final List<Gasto> gastos;

  const ReporteGastos({
    required this.cantidad,
    required this.totalSinIva,
    required this.totalIva,
    required this.totalConIva,
    required this.gastos,
  });

  factory ReporteGastos.fromJson(Map<String, dynamic> json) {
    final lista = (json['gastos'] as List<dynamic>? ?? [])
        .map((g) => Gasto.fromJson(g as Map<String, dynamic>))
        .toList();
    return ReporteGastos(
      cantidad: (json['cantidad'] as num?)?.toInt() ?? lista.length,
      totalSinIva: aDouble(json['totalSinIva']),
      totalIva: aDouble(json['totalIva']),
      totalConIva: aDouble(json['totalConIva']),
      gastos: lista,
    );
  }
}
