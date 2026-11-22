import 'package:material_ui/material_ui.dart';

import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../../utils/validaciones.dart';
import '../../widgets/mensaje_estado.dart';

/// Registro de una cuenta nueva (equivale a RegisterActivity del Corte 3 y Screen3 de Kodular).
/// Valida en el celular con las mismas reglas del backend, para no hacer viajes inútiles,
/// y luego envía POST /api/auth/register. La cuenta queda como MEMBER y activa.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  final AuthService _auth = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;
  String _estado = '';
  bool _estadoEsError = false;

  @override
  void dispose() {
    for (final c in [_username, _nombre, _email, _password, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    setState(() => _estado = '');
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _estado = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
      _estadoEsError = false;
    });
    try {
      final usuario = await _auth.registrar(
        username: _username.text.trim(),
        name: _nombre.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
      );
      // Vuelve al login y le entrega el username para dejarlo escrito.
      Navigator.of(context).pop(usuario.username);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _estado = e.mensaje; // por ejemplo, 409: usuario o correo repetido
        _estadoEsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _campo(
                controlador: _username,
                etiqueta: 'Usuario',
                icono: Icons.alternate_email,
                validador: Validaciones.username,
              ),
              _campo(
                controlador: _nombre,
                etiqueta: 'Nombre completo',
                icono: Icons.badge_outlined,
                validador: Validaciones.nombre,
                mayusculas: TextCapitalization.words,
              ),
              _campo(
                controlador: _email,
                etiqueta: 'Correo',
                icono: Icons.email_outlined,
                validador: Validaciones.email,
                teclado: TextInputType.emailAddress,
              ),
              _campo(
                controlador: _password,
                etiqueta: 'Contraseña',
                icono: Icons.lock_outline,
                validador: Validaciones.password,
                esPassword: true,
              ),
              _campo(
                controlador: _confirmar,
                etiqueta: 'Confirmar contraseña',
                icono: Icons.lock_reset,
                esPassword: true,
                validador: (valor) =>
                    valor == _password.text ? null : 'Las contraseñas no coinciden.',
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _cargando ? null : _registrar,
                child: const Text('Registrarme'),
              ),
              if (_cargando) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              MensajeEstado(texto: _estado, esError: _estadoEsError),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _cargando ? null : () => Navigator.of(context).pop(),
                child: const Text('Ya tengo una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Un campo del formulario. Se escribe una vez y se reutiliza para los cinco.
  Widget _campo({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    required String? Function(String?) validador,
    TextInputType teclado = TextInputType.text,
    TextCapitalization mayusculas = TextCapitalization.none,
    bool esPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controlador,
        enabled: !_cargando,
        keyboardType: teclado,
        textCapitalization: mayusculas,
        obscureText: esPassword && _ocultarPassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          suffixIcon: esPassword
              ? IconButton(
                  tooltip: _ocultarPassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                )
              : null,
        ),
        validator: validador,
      ),
    );
  }
}
