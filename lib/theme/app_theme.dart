import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Tema de toda la app: se define una vez y todas las pantallas lo heredan.
/// Equivale a themes.xml del Corte 3.
class AppTheme {
  AppTheme._();

  /// Fuente de títulos y botones (assets/fonts/Poppins-Bold.ttf).
  static const String fuenteTitulos = 'Poppins';

  static ThemeData claro() {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.azul,
      primary: AppColors.azul,
      onPrimary: Colors.white,
      secondary: AppColors.ambar,
      onSecondary: AppColors.azul,
      tertiary: AppColors.verde,
      onTertiary: Colors.white,
      surface: Colors.white,
    );

    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fondo,
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: fuenteTitulos,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fuenteTitulos,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.ambar),
    );
  }
}
