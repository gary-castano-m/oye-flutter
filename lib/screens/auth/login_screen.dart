import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/navegacion.dart';
import '../../utils/validaciones.dart';
import '../../widgets/encabezado_marca.dart';
import '../../widgets/mensaje_estado.dart';
import '../../widgets/swoosh.dart';
import 'recuperar_dialog.dart';
import 'registro_screen.dart';

/// Inicio de sesión (equivale a LoginActivity del Corte 3 y Screen2 de Kodular).
/// Acepta username o correo, guarda el token y abre el menú.
/// Desde aquí se recupera la contraseña por correo y se crea una cuenta.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// La "llave" del formulario: permite validar todos los campos de una vez.
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _password = TextEditingController();

  final AuthService _auth = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;
  String _estado = '';
  bool _estadoEsError = false;

  @override
  void dispose() {
    // Los controladores se liberan al cerrar la pantalla.
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    setState(() => _estado = '');
    if (!_formulario.currentState!.validate()) return;

    _mostrarCargando(true);
    try {
      final login = await _auth.login(_usuario.text.trim(), _password.text);
      await SessionService.instance.guardarSesion(login);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, ${login.user.name}')),
      );
      Navegacion.irAlMenu(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      _mostrarCargando(false);
      _mostrarEstado(e.mensaje, esError: true);
    }
  }

  Future<void> _recuperarClave() async {
    final email = await mostrarDialogoRecuperar(context);
    if (email == null) return; // tocó Cancelar

    _mostrarCargando(true);
    try {
      await _auth.recuperarClave(email);
      if (!mounted) return;
      _mostrarCargando(false);
      _mostrarEstado(
        'Si el correo está registrado, te llegará una contraseña temporal. '
        'Revisa también la carpeta de spam.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _mostrarCargando(false);
      _mostrarEstado(e.mensaje, esError: true);
    }
  }

  Future<void> _abrirRegistro() async {
    // El registro devuelve el username creado, para dejarlo escrito aquí.
    final username = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
    if (username != null && mounted) {
      setState(() {
        _usuario.text = username;
        _password.clear();
        _estado = '';
      });
    }
  }

  void _mostrarCargando(bool cargando) {
    setState(() {
      _cargando = cargando;
      if (cargando) {
        _estado = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
        _estadoEsError = false;
      }
    });
  }

  void _mostrarEstado(String texto, {bool esError = false}) {
    setState(() {
      _estado = texto;
      _estadoEsError = esError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const EncabezadoMarca(
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Tu dinero, bajo control.',
                    style: TextStyle(
                      fontFamily: AppTheme.fuenteTitulos,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '¡Empieza hoy!',
                    style: TextStyle(
                      fontFamily: AppTheme.fuenteTitulos,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                      color: AppColors.ambar,
                    ),
                  ),
                  Swoosh(ancho: 130),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontFamily: AppTheme.fuenteTitulos,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: AppColors.azul,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usuario,
                        enabled: !_cargando,
                        decoration: const InputDecoration(
                          labelText: 'Usuario o correo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validaciones.obligatorio,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        enabled: !_cargando,
                        obscureText: _ocultarPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _ocultarPassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                            icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _iniciarSesion(),
                        validator: Validaciones.password,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _cargando ? null : _iniciarSesion,
                        child: const Text('Iniciar sesión'),
                      ),
                      if (_cargando) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      MensajeEstado(texto: _estado, esError: _estadoEsError),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _cargando ? null : _recuperarClave,
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                      TextButton(
                        onPressed: _cargando ? null : _abrirRegistro,
                        child: const Text('Crear una cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
