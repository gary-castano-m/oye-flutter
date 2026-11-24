// Pruebas del JSON que se envía al guardar un usuario y de las etiquetas en español.
import 'package:flutter_test/flutter_test.dart';

import 'package:oye_flutter/services/usuario_service.dart';
import 'package:oye_flutter/utils/etiquetas.dart';

void main() {
  test('cuerpo: con contraseña vacía no se envía (no se cambia)', () {
    final json = UsuarioService.cuerpo(username: 'gary', name: 'Gary', email: 'g@x.co');
    expect(json.containsKey('password'), isFalse);
    expect(json.containsKey('role'), isFalse);
    expect(json['email'], 'g@x.co');
  });

  test('cuerpo: incluye contraseña, rol y estado cuando se dan', () {
    final json = UsuarioService.cuerpo(
      username: 'gary',
      name: 'Gary',
      email: 'g@x.co',
      password: '12345678',
      role: 'REVIEWER',
      status: 'BLOCKED',
    );
    expect(json['password'], '12345678');
    expect(json['role'], 'REVIEWER');
    expect(json['status'], 'BLOCKED');
  });

  test('etiquetas: roles y estados en español', () {
    expect(Etiquetas.rol('ADMIN'), 'Administrador');
    expect(Etiquetas.rol('MEMBER'), 'Miembro');
    expect(Etiquetas.estado('ACTIVE'), 'Activo');
    expect(Etiquetas.estado('BLOCKED'), 'Bloqueado');
    expect(Etiquetas.roles.length, 3);
    expect(Etiquetas.estados.length, 4);
  });
}
