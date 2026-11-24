import 'package:material_ui/material_ui.dart';

import '../../models/usuario.dart';
import '../../services/api_exception.dart';
import '../../services/session_service.dart';
import '../../services/usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/etiquetas.dart';
import 'usuario_form_screen.dart';

/// CRUD de la tabla Usuario, solo ADMIN (equivale a UsuariosActivity del Corte 3
/// y a Screen11 de Kodular).
/// GET /api/users al abrir; al tocar un usuario: editar o eliminar (DELETE /api/users/{id}).
/// El ADMIN no puede eliminar su propia cuenta.
class UsuariosListaScreen extends StatefulWidget {
  const UsuariosListaScreen({super.key});

  @override
  State<UsuariosListaScreen> createState() => _UsuariosListaScreenState();
}

class _UsuariosListaScreenState extends State<UsuariosListaScreen> {
  final UsuarioService _servicio = UsuarioService();

  List<Usuario> _usuarios = [];
  String? _miId;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  Future<void> _preparar() async {
    final yo = await SessionService.instance.leerUsuario();
    _miId = yo?.id;
    await _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final usuarios = await _servicio.listar();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _abrirFormulario({Usuario? usuario}) async {
    final huboCambios = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UsuarioFormScreen(usuario: usuario)),
    );
    if (huboCambios == true) await _cargarUsuarios();
  }

  Future<void> _mostrarOpciones(Usuario usuario) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(usuario.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('@${usuario.username} · ${usuario.email}'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () => Navigator.of(hoja).pop('editar'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.of(hoja).pop('eliminar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (opcion == 'editar') await _abrirFormulario(usuario: usuario);
    if (opcion == 'eliminar') {
      if (usuario.id == _miId) {
        _avisar('No puedes eliminar tu propia cuenta.');
      } else {
        await _confirmarEliminar(usuario);
      }
    }
  }

  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar a ${usuario.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogo).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(dialogo).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _cargando = true);
    try {
      await _servicio.eliminar(usuario.id);
      if (!mounted) return;
      _avisar('Usuario eliminado.');
      await _cargarUsuarios();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _avisar(e.mensaje);
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.ambar,
        foregroundColor: AppColors.azul,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Nuevo usuario'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.azulClaro,
            padding: const EdgeInsets.all(16),
            child: Text(
              _error ?? 'Usuarios registrados: ${_usuarios.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _error == null ? AppColors.azul : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          if (_cargando) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarUsuarios,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                itemCount: _usuarios.length,
                itemBuilder: (_, i) => _FilaUsuario(
                  usuario: _usuarios[i],
                  esYo: _usuarios[i].id == _miId,
                  alTocar: () => _mostrarOpciones(_usuarios[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una fila de la lista (equivale a item_usuario.xml + UsuarioAdapter del Corte 3).
class _FilaUsuario extends StatelessWidget {
  const _FilaUsuario({required this.usuario, required this.esYo, required this.alTocar});

  final Usuario usuario;
  final bool esYo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final activo = usuario.status == 'ACTIVE';
    return Card(
      child: ListTile(
        onTap: alTocar,
        leading: CircleAvatar(
          backgroundColor: usuario.esAdmin ? AppColors.ambar : AppColors.azulClaro,
          foregroundColor: AppColors.azul,
          child: Text(usuario.name.isEmpty ? '?' : usuario.name[0].toUpperCase()),
        ),
        title: Text(
          esYo ? '${usuario.name} (tú)' : usuario.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('@${usuario.username} · ${usuario.email}\n'
            '${Etiquetas.rol(usuario.role)} · ${Etiquetas.estado(usuario.status)}'),
        isThreeLine: true,
        trailing: Icon(
          activo ? Icons.check_circle : Icons.block,
          color: activo ? AppColors.verde : Colors.grey,
        ),
      ),
    );
  }
}
