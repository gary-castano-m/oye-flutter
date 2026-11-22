import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/navegacion.dart';
import '../widgets/swoosh.dart';

/// Primera pantalla (equivale a SplashActivity del Corte 3 y Screen1 de Kodular).
/// Mientras se ve el logo, despierta Render y luego va al login.
/// Si hay una sesión guardada, la verifica con /api/users/me y salta directo al menú.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();
  final SessionService _sesion = SessionService.instance;

  /// Tiempo mínimo del splash, para que el logo alcance a verse aunque Render ya esté despierto.
  static const Duration _tiempoMinimo = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  Future<void> _arrancar() async {
    final reloj = Stopwatch()..start();
    var sesionValida = false;

    if (await _sesion.haySesion()) {
      try {
        final usuario = await _auth.miPerfil();
        await _sesion.actualizarUsuario(usuario);
        sesionValida = true;
      } on ApiException {
        // Token vencido o sin conexión: se vuelve a iniciar sesión.
        await _sesion.cerrarSesion();
      }
    } else {
      try {
        await _auth.despertar();
      } on ApiException {
        // Aunque falle, se sigue al login; allí se verá el error si no hay internet.
      }
    }

    final falta = _tiempoMinimo - reloj.elapsed;
    if (falta > Duration.zero) await Future<void>.delayed(falta);

    if (!mounted) return;
    if (sesionValida) {
      Navegacion.irAlMenu(context);
    } else {
      Navegacion.irAlLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Íconos de la barra de estado en blanco, porque el fondo es azul.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.azul,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_oye_blanco.png',
                    width: 260,
                    semanticLabel: 'Logo de Oye!',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu dinero, bajo control.',
                    style: TextStyle(
                      fontFamily: AppTheme.fuenteTitulos,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '¡Empieza hoy!',
                    style: TextStyle(
                      fontFamily: AppTheme.fuenteTitulos,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 24,
                      color: AppColors.ambar,
                    ),
                  ),
                  const Swoosh(),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text(
                    'Despertando el servidor…',
                    style: TextStyle(color: AppColors.textoSuave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
