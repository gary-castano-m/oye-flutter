import 'package:material_ui/material_ui.dart';

import '../../models/usuario.dart';
import '../../services/api_exception.dart';
import '../../services/usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/etiquetas.dart';
import '../../utils/validaciones.dart';
import '../../widgets/fila_usuario.dart';
import '../../widgets/mensaje_estado.dart';

/// Los dos reportes parametrizados de la tabla Usuario, solo ADMIN
/// (equivale a ReporteUsuariosActivity del Corte 3):
/// - Por rol:    GET /api/users/reports?role=REVIEWER
/// - Por nombre: GET /api/users/reports?name=gar   (coincidencia parcial)
class ReporteUsuariosScreen extends StatefulWidget {
  const ReporteUsuariosScreen({super.key});

  @override
  State<ReporteUsuariosScreen> createState() => _ReporteUsuariosScreenState();
}

enum _TipoReporte { rol, nombre }

class _ReporteUsuariosScreenState extends State<ReporteUsuariosScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final UsuarioService _servicio = UsuarioService();

  _TipoReporte _tipo = _TipoReporte.rol;
  String _rol = Usuario.rolMember;
  List<Usuario>? _resultado;
  bool _cargando = false;
  String _mensaje = '';

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _generar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _mensaje = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
    });
    try {
      final usuarios = _tipo == _TipoReporte.rol
          ? await _servicio.reporte(rol: _rol)
          : await _servicio.reporte(nombre: _nombre.text.trim());
      if (!mounted) return;
      setState(() {
        _resultado = usuarios;
        _cargando = false;
        _mensaje = usuarios.isEmpty ? 'No hay usuarios con ese filtro.' : '';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensaje = e.mensaje;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de usuarios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_TipoReporte>(
            segments: const [
              ButtonSegment(
                value: _TipoReporte.rol,
                label: Text('Por rol'),
                icon: Icon(Icons.admin_panel_settings_outlined),
              ),
              ButtonSegment(
                value: _TipoReporte.nombre,
                label: Text('Por nombre'),
                icon: Icon(Icons.search),
              ),
            ],
            selected: {_tipo},
            onSelectionChanged: (seleccion) => setState(() {
              _tipo = seleccion.first;
              _resultado = null;
              _mensaje = '';
            }),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formulario,
            child: _tipo == _TipoReporte.rol
                ? DropdownButtonFormField<String>(
                    initialValue: _rol,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: [
                      for (final r in Etiquetas.roles)
                        DropdownMenuItem(value: r, child: Text(Etiquetas.rol(r))),
                    ],
                    onChanged: (r) => setState(() => _rol = r!),
                  )
                : TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre (o parte del nombre)',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _generar(),
                    validator: Validaciones.obligatorio,
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargando ? null : _generar,
            child: const Text('Generar reporte'),
          ),
          if (_cargando) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          MensajeEstado(texto: _mensaje),
          if (resultado != null && resultado.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: AppColors.azulClaro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Usuarios encontrados: ${resultado.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final u in resultado) FilaUsuario(usuario: u),
          ],
        ],
      ),
    );
  }
}
