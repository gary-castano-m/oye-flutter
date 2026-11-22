import 'package:material_ui/material_ui.dart';

import '../screens/auth/login_screen.dart';
import '../screens/menu/menu_screen.dart';

/// Saltos entre pantallas que borran el historial, para que "atrás" no regrese
/// al splash ni al login después de entrar. Equivale a Navegacion.java del Corte 3
/// (FLAG_ACTIVITY_CLEAR_TASK).
class Navegacion {
  Navegacion._();

  static void irAlLogin(BuildContext context) => _reemplazarTodo(context, const LoginScreen());

  static void irAlMenu(BuildContext context) => _reemplazarTodo(context, const MenuScreen());

  static void _reemplazarTodo(BuildContext context, Widget pantalla) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => pantalla),
      (_) => false,
    );
  }
}
