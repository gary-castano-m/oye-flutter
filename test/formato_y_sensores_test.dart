// Pruebas de los formatos de dinero y fecha, y del cálculo del acelerómetro.
import 'package:flutter_test/flutter_test.dart';

import 'package:oye_flutter/sensors/detector_agitar.dart';
import 'package:oye_flutter/sensors/ubicacion_service.dart';
import 'package:oye_flutter/utils/formato.dart';

void main() {
  test('dinero: separador de miles con punto y decimales con coma', () {
    expect(Formato.dinero(11900), '\$ 11.900');
    expect(Formato.dinero(1234567), '\$ 1.234.567');
    expect(Formato.dinero(1234.5), '\$ 1.234,5');
    expect(Formato.dinero(99.99), '\$ 99,99');
    expect(Formato.dinero(0), '\$ 0');
  });

  test('fecha: de la API a dd/MM/yyyy y de vuelta', () {
    expect(Formato.fecha('2026-11-03'), '03/11/2026');
    expect(Formato.fechaIso(DateTime(2026, 1, 5)), '2026-01-05');
    expect(Formato.leerFechaIso('2026-11-22'), DateTime(2026, 11, 22));
  });

  test('leerValor: acepta punto o coma y rechaza texto', () {
    expect(Formato.leerValor('10000'), 10000);
    expect(Formato.leerValor('10000,50'), 10000.5);
    expect(Formato.leerValor('abc'), isNull);
    expect(Formato.leerValor(''), isNull);
  });

  test('acelerómetro: quieto marca 1 g; un sacudón pasa de 2,5 g', () {
    expect(DetectorAgitar.fuerzaEnG(0, 0, 9.80665), closeTo(1.0, 0.001));
    expect(DetectorAgitar.fuerzaEnG(20, 15, 9.8) > DetectorAgitar.umbralG, isTrue);
    expect(DetectorAgitar.fuerzaEnG(3, 2, 9.8) > DetectorAgitar.umbralG, isFalse);
  });

  test('ubicación: formato de coordenadas igual al del Corte 3', () {
    expect(UbicacionService.coordenadas(10.391, -75.479), 'Lat 10.39100, Lng -75.47900');
  });
}
