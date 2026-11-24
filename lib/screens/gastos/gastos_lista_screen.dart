import 'package:material_ui/material_ui.dart';

import '../../models/gasto.dart';
import '../../models/usuario.dart';
import '../../sensors/detector_agitar.dart';
import '../../services/api_exception.dart';
import '../../services/gasto_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formato.dart';
import 'gasto_form_screen.dart';

/// Lista de gastos (equivale a GastosListActivity del Corte 3 y a Screen7 de Kodular).
/// GET /api/gastos al abrir y al volver de crear o editar.
/// Al tocar un gasto se puede editar o eliminar (DELETE /api/gastos/{id}).
/// Sensor acelerómetro: al agitar el celular se vuelve a pedir la lista.
class GastosListaScreen extends StatefulWidget {
  const GastosListaScreen({super.key});

  @override
  State<GastosListaScreen> createState() => _GastosListaScreenState();
}

class _GastosListaScreenState extends State<GastosListaScreen> {
  final GastoService _servicio = GastoService();
  late final DetectorAgitar _detector;

  List<Gasto> _gastos = [];
  bool _cargando = true;
  String? _error;
  bool _veTodos = false; // ADMIN y REVIEWER ven gastos de todos: se muestra de quién es cada uno

  @override
  void initState() {
    super.initState();
    _detector = DetectorAgitar(alAgitar: () {
      _avisar('Actualizando la lista…');
      _cargarGastos();
    });
    _detector.iniciar(); // el acelerómetro escucha solo mientras esta pantalla está al frente
    _prepararPantalla();
  }

  @override
  void dispose() {
    _detector.detener();
    super.dispose();
  }

  Future<void> _prepararPantalla() async {
    final usuario = await SessionService.instance.leerUsuario();
    if (!mounted) return;
    setState(() => _veTodos = usuario != null && usuario.role != Usuario.rolMember);
    await _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final gastos = await _servicio.listar();
      if (!mounted) return;
      setState(() {
        _gastos = gastos;
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

  /// Abre el formulario. Mientras está abierto, el acelerómetro se pausa (como onPause en Android).
  Future<void> _abrirFormulario({String? gastoId}) async {
    _detector.detener();
    final huboCambios = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => GastoFormScreen(gastoId: gastoId)),
    );
    if (!mounted) return;
    _detector.iniciar();
    if (huboCambios == true) await _cargarGastos();
  }

  /// Menú inferior con las opciones del gasto tocado.
  Future<void> _mostrarOpciones(Gasto gasto) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(gasto.lugar, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${Formato.fecha(gasto.fecha)} · ${Formato.dinero(gasto.valorTotalConIva)}'),
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
    if (opcion == 'editar') await _abrirFormulario(gastoId: gasto.id);
    if (opcion == 'eliminar') await _confirmarEliminar(gasto);
  }

  Future<void> _confirmarEliminar(Gasto gasto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar el gasto de ${gasto.lugar} por ${Formato.dinero(gasto.valorTotalConIva)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogo).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(dialogo).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _cargando = true);
    try {
      await _servicio.eliminar(gasto.id);
      if (!mounted) return;
      _avisar('Gasto eliminado.');
      await _cargarGastos();
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
    final total = _gastos.fold<double>(0, (suma, g) => suma + g.valorTotalConIva);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.ambar,
        foregroundColor: AppColors.azul,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Resumen y aviso del sensor
          Container(
            color: AppColors.azulClaro,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error ?? 'Gastos: ${_gastos.length} · Total: ${Formato.dinero(total)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _error == null ? AppColors.azul : Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.vibration, size: 16, color: AppColors.azul),
                    SizedBox(width: 6),
                    Expanded(child: Text('Agita el celular para actualizar la lista.')),
                  ],
                ),
              ],
            ),
          ),
          if (_cargando) const LinearProgressIndicator(),
          Expanded(
            // Además del sensor, se puede deslizar hacia abajo para actualizar.
            child: RefreshIndicator(
              onRefresh: _cargarGastos,
              child: _gastos.isEmpty && !_cargando && _error == null
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Aún no hay gastos. Toca «Nuevo gasto» para registrar el primero.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88), // espacio para el botón flotante
                      itemCount: _gastos.length,
                      itemBuilder: (_, i) => _FilaGasto(
                        gasto: _gastos[i],
                        mostrarUsuario: _veTodos,
                        alTocar: () => _mostrarOpciones(_gastos[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una fila de la lista (equivale a item_gasto.xml + GastoAdapter del Corte 3).
class _FilaGasto extends StatelessWidget {
  const _FilaGasto({required this.gasto, required this.mostrarUsuario, required this.alTocar});

  final Gasto gasto;
  final bool mostrarUsuario;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gasto.lugar,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formato.dinero(gasto.valorTotalConIva),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.verde,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(Formato.fecha(gasto.fecha), style: const TextStyle(color: Colors.black54)),
              if (gasto.descripcion.isNotEmpty) Text(gasto.descripcion),
              if (mostrarUsuario && gasto.nombreUsuario.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Registrado por: ${gasto.nombreUsuario}',
                    style: const TextStyle(fontSize: 12, color: AppColors.azul),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
