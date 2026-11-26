// Prueba de widget del reporte de gastos: sin celular ni internet, revisa que
// el reporte por lugar exija escribir el lugar antes de consultar al servidor.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oye_flutter/screens/reportes/reporte_gastos_screen.dart';
import 'package:oye_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Reporte de gastos: por lugar pide el lugar', (tester) async {
    // La pantalla lee la sesión al abrir: en las pruebas se usa una sesión vacía en memoria.
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(theme: AppTheme.claro(), home: const ReporteGastosScreen()));

    // Por defecto está el reporte por fechas, con las dos fechas llenas.
    expect(find.text('Desde'), findsOneWidget);
    expect(find.text('Hasta'), findsOneWidget);

    // Cambia al reporte por lugar y genera con el campo vacío.
    await tester.tap(find.text('Por lugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar reporte'));
    await tester.pump();

    expect(find.text('Este campo es obligatorio.'), findsOneWidget);
  });
}
