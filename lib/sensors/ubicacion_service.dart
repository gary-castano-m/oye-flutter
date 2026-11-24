import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Error del sensor de ubicación, con un mensaje listo para mostrar.
class UbicacionException implements Exception {
  final String mensaje;
  const UbicacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// SENSOR 1 · Ubicación (GPS) — equivale a LocationHelper del Corte 3
/// y al LocationSensor de Kodular.
/// 1. Revisa que el GPS esté encendido y que haya permiso (si no, lo pide).
/// 2. Toma una sola lectura de latitud y longitud.
/// 3. La convierte en dirección con el Geocoder de Android ("geocodificación inversa").
///    Si no hay dirección, devuelve las coordenadas.
class UbicacionService {
  /// El backend acepta hasta 100 caracteres en "lugar".
  static const int largoMaximoLugar = 100;

  final Geocoding _geocoding = Geocoding(locale: const Locale('es', 'CO'));

  Future<String> obtenerLugar() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionException('El GPS está apagado: enciéndelo o escribe el lugar a mano.');
    }

    // Permiso: la primera vez Android muestra "¿Permitir que Oye! acceda a tu ubicación?".
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw const UbicacionException('Sin permiso de ubicación: escribe el lugar a mano.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const UbicacionException(
        'El permiso de ubicación está bloqueado. Actívalo en Ajustes > Apps > oye_flutter > Permisos.',
      );
    }

    final Position posicion;
    try {
      posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      throw const UbicacionException('No se pudo leer la ubicación. Revisa que el GPS esté encendido.');
    }

    return _direccion(posicion.latitude, posicion.longitude);
  }

  Future<String> _direccion(double lat, double lng) async {
    try {
      final lugares = await _geocoding.placemarkFromCoordinates(lat, lng);
      final direccion = lugares.isEmpty ? null : lugares.first.street?.trim();
      if (direccion == null || direccion.isEmpty) return coordenadas(lat, lng);
      return direccion.length > largoMaximoLugar
          ? direccion.substring(0, largoMaximoLugar)
          : direccion;
    } catch (_) {
      // Sin internet o sin servicio de direcciones: se usan las coordenadas.
      return coordenadas(lat, lng);
    }
  }

  /// Mismo formato del Corte 3: "Lat 10.39100, Lng -75.47900".
  static String coordenadas(double lat, double lng) =>
      'Lat ${lat.toStringAsFixed(5)}, Lng ${lng.toStringAsFixed(5)}';
}
