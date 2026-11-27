import 'package:material_ui/material_ui.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

/// Punto de entrada de la app: aquí arranca todo.
void main() {
  runApp(const OyeApp());
}

class OyeApp extends StatelessWidget {
  const OyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oye!',
      debugShowCheckedModeBanner: false, // quita la cinta "DEBUG"
      theme: AppTheme.claro(),
      themeMode: ThemeMode.light, // tema claro siempre, como en el Corte 3

      // Español de Colombia para los componentes del sistema:
      // calendario, botones "Aceptar/Cancelar", "Pegar", formatos de fecha, etc.
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      home: const SplashScreen(),
    );
  }
}
