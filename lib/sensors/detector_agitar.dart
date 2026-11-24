import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// SENSOR 2 · Acelerómetro — equivale a ShakeDetector del Corte 3
/// y al evento AccelerometerSensor.Shaking de Kodular.
/// Mide la aceleración en x, y, z. Quieto, el celular marca 1 g (la gravedad).
/// Si la fuerza total pasa de 2,5 g, se considera que lo agitaron.
class DetectorAgitar {
  DetectorAgitar({required this.alAgitar});

  /// Qué hacer cuando agitan el celular.
  final void Function() alAgitar;

  static const double umbralG = 2.5;
  static const double gravedad = 9.80665; // m/s²
  static const Duration esperaEntreAgitones = Duration(milliseconds: 1500);

  StreamSubscription<AccelerometerEvent>? _suscripcion;
  DateTime _ultimoAgiton = DateTime.fromMillisecondsSinceEpoch(0);

  /// Empieza a escuchar. Se llama mientras la pantalla de la lista está visible.
  void iniciar() {
    _suscripcion ??= accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (evento) {
        if (fuerzaEnG(evento.x, evento.y, evento.z) > umbralG) {
          final ahora = DateTime.now();
          // Evita recargar varias veces con un mismo movimiento.
          if (ahora.difference(_ultimoAgiton) > esperaEntreAgitones) {
            _ultimoAgiton = ahora;
            alAgitar();
          }
        }
      },
      onError: (_) => detener(), // celular sin acelerómetro: simplemente no se usa
      cancelOnError: true,
    );
  }

  /// Deja de escuchar, para no gastar batería.
  void detener() {
    _suscripcion?.cancel();
    _suscripcion = null;
  }

  /// Fuerza total en "g": √(x² + y² + z²) / 9,8. Es pública para poder probarla.
  static double fuerzaEnG(double x, double y, double z) =>
      sqrt(x * x + y * y + z * z) / gravedad;
}
