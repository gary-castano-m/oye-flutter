import 'package:material_ui/material_ui.dart';

import '../../models/usuario.dart';
import '../../services/api_exception.dart';
import '../../services/session_service.dart';
import '../../services/usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/etiquetas.dart';
import '../../utils/validaciones.dart';
import '../../widgets/mensaje_estado.dart';

/// Crear o editar un usuario, solo ADMIN (equivale a UsuarioFormActivity del Corte 3).
/// - Sin usuario: POST /api/users. La contraseña es obligatoria y la cuenta queda activa.
/// - Con usuario: PUT /api/users/{id}. Contraseña vacía = no se cambia.
/// El ADMIN no puede cambiar su propio rol ni su estado, para no quedarse sin acceso.
class UsuarioFormScreen extends StatefulWidget {
  const UsuarioFormScreen({super.key, this.usuario});

  final Usuario? usuario; // null = usuario nuevo

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formulario = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final UsuarioService _servicio = UsuarioService();

  String _rol = Usuario.rolMember;
  String _estado = 'ACTIVE';
  bool _esMiCuenta = false;
  bool _cargando = false;
  bool _ocultarPassword = true;
  String _mensaje = '';
  bool _mensajeEsError = false;

  bool get _esNuevo => widget.usuario == null;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    if (u != null) {
      _username.text = u.username;
      _nombre.text = u.name;
      _email.text = u.email;
      if (Etiquetas.roles.contains(u.role)) _rol = u.role;
      if (Etiquetas.estados.contains(u.status)) _estado = u.status;
      _revisarSiEsMiCuenta(u.id);
    }
  }

  Future<void> _revisarSiEsMiCuenta(String id) async {
    final yo = await SessionService.instance.leerUsuario();
    if (!mounted || yo == null || yo.id != id) return;
    setState(() {
      _esMiCuenta = true;
      _mensaje = 'Es tu propia cuenta: el rol y el estado no se pueden cambiar aquí.';
    });
  }

  @override
  void dispose() {
    for (final c in [_username, _nombre, _email, _password]) {
      c.dispose();
    }
    super.dispose();
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
      final guardado = _esNuevo
          ? await _servicio.crear(
              username: _username.text.trim(),
              name: _nombre.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
              role: _rol,
            )
          : await _servicio.actualizar(
              widget.usuario!.id,
              username: _username.text.trim(),
              name: _nombre.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
              role: _rol,
              status: _estado,
            );
      // Si el ADMIN editó su propia cuenta, el menú debe mostrar el nombre nuevo.
      if (_esMiCuenta) await SessionService.instance.actualizarUsuario(guardado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario guardado.')));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensaje = e.mensaje; // por ejemplo, 409: usuario o correo repetido
        _mensajeEsError = true;
      });
    }
  }

  /// Al crear, la contraseña es obligatoria. Al editar, solo se revisa si se escribió algo.
  String? _validarPassword(String? valor) {
    if (!_esNuevo && (valor ?? '').isEmpty) return null;
    return Validaciones.password(valor);
  }

  @override
  Widget build(BuildContext context) {
    final bloqueaRolYEstado = _cargando || _esMiCuenta;

    return Scaffold(
      appBar: AppBar(title: Text(_esNuevo ? 'Nuevo usuario' : 'Editar usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _username,
                enabled: !_cargando,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: Validaciones.username,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                enabled: !_cargando,
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
                enabled: !_cargando,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validaciones.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: !_cargando,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: _esNuevo ? 'Contraseña' : 'Nueva contraseña (opcional)',
                  helperText: _esNuevo ? null : 'Si la dejas vacía, sigue la misma.',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _ocultarPassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
                validator: _validarPassword,
              ),
              const SizedBox(height: 16),
              // Lista desplegable del rol (el Spinner del Corte 3).
              DropdownButtonFormField<String>(
                initialValue: _rol,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: [
                  for (final r in Etiquetas.roles)
                    DropdownMenuItem(value: r, child: Text(Etiquetas.rol(r))),
                ],
                onChanged: bloqueaRolYEstado ? null : (r) => setState(() => _rol = r!),
              ),
              // El estado solo se elige al editar: un usuario nuevo siempre queda activo.
              if (!_esNuevo) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.toggle_on_outlined),
                  ),
                  items: [
                    for (final e in Etiquetas.estados)
                      DropdownMenuItem(value: e, child: Text(Etiquetas.estado(e))),
                  ],
                  onChanged: bloqueaRolYEstado ? null : (e) => setState(() => _estado = e!),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : _guardar,
                child: const Text('Guardar usuario'),
              ),
              if (_cargando) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              MensajeEstado(texto: _mensaje, esError: _mensajeEsError),
              if (_esNuevo)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'La cuenta quedará activa y podrá iniciar sesión de inmediato.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.azul),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
