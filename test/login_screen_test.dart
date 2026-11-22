// Prueba de widget: abre la pantalla de login en memoria (sin celular ni internet),
// toca el botón con los campos vacíos y revisa que aparezcan los errores.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:oye_flutter/screens/auth/login_screen.dart';
import 'package:oye_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Login: valida los campos antes de conectarse', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.claro(), home: const LoginScreen()));

    final boton = find.widgetWithText(ElevatedButton, 'Iniciar sesión');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    expect(find.text('La contraseña debe tener al menos 8 caracteres.'), findsOneWidget);
  });
}
