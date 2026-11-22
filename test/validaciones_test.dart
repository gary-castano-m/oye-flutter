// Pruebas de las reglas de validación de los formularios.
import 'package:flutter_test/flutter_test.dart';

import 'package:oye_flutter/utils/validaciones.dart';

void main() {
  test('obligatorio: rechaza vacío y solo espacios', () {
    expect(Validaciones.obligatorio(''), isNotNull);
    expect(Validaciones.obligatorio('   '), isNotNull);
    expect(Validaciones.obligatorio('gary'), isNull);
  });

  test('email: acepta un correo y rechaza texto suelto', () {
    expect(Validaciones.email('gcastanom@unicartagena.edu.co'), isNull);
    expect(Validaciones.email('gary'), isNotNull);
    expect(Validaciones.email('gary@correo'), isNotNull);
  });

  test('username: entre 3 y 30, sin espacios', () {
    expect(Validaciones.username('gary.castano'), isNull);
    expect(Validaciones.username('ga'), isNotNull);
    expect(Validaciones.username('gary castano'), isNotNull);
  });

  test('password: mínimo 8 caracteres', () {
    expect(Validaciones.password('1234567'), isNotNull);
    expect(Validaciones.password('12345678'), isNull);
  });
}
