import 'package:material_ui/material_ui.dart';

import '../../services/api_exception.dart';
import '../../services/session_service.dart';
import '../../services/usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/etiquetas.dart';
import '../../utils/validaciones.dart';
import '../../widgets/mensaje_estado.dart';

/// Mi perfil (equivale a PerfilActivity del Corte 3 y a Screen8 de Kodular).
/// Usa /api/users/me: no lleva id porque el usuario sale del token.
/// Cualquier rol puede cambiar su usuario, nombre, correo y contraseña.
/// Si la contraseña se deja vacía, no se cambia.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formulario = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  final UsuarioService _servicio = UsuarioService();

  String _rol = '';
  bool _cargando = true;
  bool _datosCargados = false;
  bool _ocultarPassword = true;
  String _mensaje = '';
  bool _mensajeEsError = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    for (final c in [_username, _nombre, _email, _password, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Trae los datos frescos del servidor, no los guardados en el celular.
  Future<void> _cargarPerfil() async {
    try {
      final yo = await _servicio.miPerfil();
      if (!mounted) return;
      setState(() {
        _username.text = yo.username;
        _nombre.text = yo.name;
        _email.text = yo.email;
        _rol = Etiquetas.rol(yo.role);
        _cargando = false;
        _datosCargados = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensaje = e.mensaje;
        _mensajeEsError = true;
      });
    }
  }

  Future<void> _guardar() async {
    setState(() => _mensaje = '');
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensaje = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
      _mensajeEsError = false;
    });
    try {
      final actualizado = await _servicio.actualizarPerfil(
        username: _username.text.trim(),
        name: _nombre.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      await SessionService.instance.actualizarUsuario(actualizado); // el menú mostrará el nombre nuevo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensaje = e.mensaje;
        _mensajeEsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = _cargando || !_datosCargados;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_rol.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.verified_user_outlined, color: AppColors.azul, size: 18),
                  label: Text('Rol: $_rol'),
                  backgroundColor: AppColors.ambarClaro,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _username,
                enabled: !bloqueado,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: Validaciones.username,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                enabled: !bloqueado,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: Validaciones.nombre,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                enabled: !bloqueado,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validaciones.email,
              ),
              const SizedBox(height: 16),
              const Text(
                'Para cambiar la contraseña, escribe una nueva. Si la dejas vacía, sigue la misma.',
                style: TextStyle(color: AppColors.azul),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _password,
                enabled: !bloqueado,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña (opcional)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _ocultarPassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
                validator: (v) => (v ?? '').isEmpty ? null : Validaciones.password(v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmar,
                enabled: !bloqueado,
                obscureText: _ocultarPassword,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) => v == _password.text ? null : 'Las contraseñas no coinciden.',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: bloqueado ? null : _guardar,
                child: const Text('Guardar cambios'),
              ),
              if (_cargando) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              MensajeEstado(texto: _mensaje, esError: _mensajeEsError),
            ],
          ),
        ),
      ),
    );
  }
}
