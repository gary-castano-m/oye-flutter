// Pruebas unitarias de los modelos: verifican que el JSON de la API
// se convierta bien en objetos Dart, sin necesidad de internet.
// Se ejecutan con:  flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:oye_flutter/models/gasto.dart';
import 'package:oye_flutter/models/login_response.dart';
import 'package:oye_flutter/models/reporte_gastos.dart';
import 'package:oye_flutter/models/usuario.dart';

void main() {
  test('Usuario: lee el JSON de la API y reconoce al admin', () {
    final usuario = Usuario.fromJson({
      'id': 'a1',
      'username': 'admin',
      'name': 'Administrador',
      'email': 'admin@oye.com',
      'role': 'ADMIN',
      'status': 'ACTIVE',
    });

    expect(usuario.name, 'Administrador');
    expect(usuario.esAdmin, isTrue);
    expect(Usuario.fromJson(usuario.toJson()).email, 'admin@oye.com');
  });

  test('Gasto: convierte los valores numéricos a double', () {
    final gasto = Gasto.fromJson({
      'id': 'g1',
      'fecha': '2026-11-20',
      'valorTotalSinIva': 10000,
      'ivaTotal': 1900.0,
      'valorTotalConIva': '11900',
      'lugar': 'Cartagena',
      'descripcion': 'Almuerzo',
    });

    expect(gasto.valorTotalSinIva, 10000.0);
    expect(gasto.ivaTotal, 1900.0);
    expect(gasto.valorTotalConIva, 11900.0);
    expect(gasto.nombreUsuario, '');
  });

  test('LoginResponse: trae el token y el usuario', () {
    final login = LoginResponse.fromJson({
      'accessToken': 'abc.def.ghi',
      'tokenType': 'Bearer',
      'expiresIn': 3600,
      'user': {'id': 'u1', 'name': 'Gary', 'role': 'MEMBER'},
    });

    expect(login.accessToken, 'abc.def.ghi');
    expect(login.user.esAdmin, isFalse);
  });

  test('ReporteGastos: lee la lista y los totales', () {
    final reporte = ReporteGastos.fromJson({
      'cantidad': 1,
      'totalSinIva': 10000,
      'totalIva': 1900,
      'totalConIva': 11900,
      'gastos': [
        {'id': 'g1', 'fecha': '2026-11-20', 'valorTotalSinIva': 10000},
      ],
    });

    expect(reporte.cantidad, 1);
    expect(reporte.gastos.first.id, 'g1');
    expect(reporte.totalConIva, 11900.0);
  });
}
