import 'package:material_ui/material_ui.dart';

import '../../models/reporte_gastos.dart';
import '../../models/usuario.dart';
import '../../services/api_exception.dart';
import '../../services/gasto_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formato.dart';
import '../../utils/validaciones.dart';
import '../../widgets/fila_gasto.dart';
import '../../widgets/mensaje_estado.dart';

/// Los dos reportes parametrizados de la tabla Gastos
/// (equivale a ReporteGastosActivity del Corte 3; une Screen9 y Screen10 de Kodular):
/// - Por rango de fechas: GET /api/gastos/reports?desde=...&hasta=...
/// - Por lugar:           GET /api/gastos/reports?lugar=...
/// La app solo arma la petición; filtrar, contar y sumar lo hace el servidor.
class ReporteGastosScreen extends StatefulWidget {
  const ReporteGastosScreen({super.key});

  @override
  State<ReporteGastosScreen> createState() => _ReporteGastosScreenState();
}

enum _TipoReporte { fechas, lugar }

class _ReporteGastosScreenState extends State<ReporteGastosScreen> {
  final _formulario = GlobalKey<FormState>();
  final _desde = TextEditingController();
  final _hasta = TextEditingController();
  final _lugar = TextEditingController();

  final GastoService _servicio = GastoService();

  _TipoReporte _tipo = _TipoReporte.fechas;
  ReporteGastos? _reporte;
  bool _veTodos = false;
  bool _cargando = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    // Por defecto: el mes actual, del día 1 hasta hoy.
    final hoy = DateTime.now();
    _desde.text = Formato.fechaIso(DateTime(hoy.year, hoy.month, 1));
    _hasta.text = Formato.fechaIso(hoy);
    _revisarRol();
  }

  Future<void> _revisarRol() async {
    final yo = await SessionService.instance.leerUsuario();
    if (!mounted) return;
    setState(() => _veTodos = yo != null && yo.role != Usuario.rolMember);
  }

  @override
  void dispose() {
    for (final c in [_desde, _hasta, _lugar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFecha(TextEditingController campo) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: Formato.leerFechaIso(campo.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null) setState(() => campo.text = Formato.fechaIso(elegida));
  }

  /// "hasta" no puede ser anterior a "desde". Las fechas yyyy-MM-dd se comparan como texto.
  String? _validarHasta(String? hasta) {
    if ((hasta ?? '').compareTo(_desde.text) < 0) {
      return 'La fecha final no puede ser anterior a la inicial.';
    }
    return null;
  }

  Future<void> _generar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _mensaje = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
    });
    try {
      final reporte = _tipo == _TipoReporte.fechas
          ? await _servicio.reporte(desde: _desde.text, hasta: _hasta.text)
          : await _servicio.reporte(lugar: _lugar.text.trim());
      if (!mounted) return;
      setState(() {
        _reporte = reporte;
        _cargando = false;
        _mensaje = reporte.cantidad == 0 ? 'No hay gastos con ese filtro.' : '';
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
    final reporte = _reporte;
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de gastos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Elegir el reporte: el RadioGroup del Corte 3.
          SegmentedButton<_TipoReporte>(
            segments: const [
              ButtonSegment(
                value: _TipoReporte.fechas,
                label: Text('Por fechas'),
                icon: Icon(Icons.date_range),
              ),
              ButtonSegment(
                value: _TipoReporte.lugar,
                label: Text('Por lugar'),
                icon: Icon(Icons.place_outlined),
              ),
            ],
            selected: {_tipo},
            onSelectionChanged: (seleccion) => setState(() {
              _tipo = seleccion.first;
              _reporte = null;
              _mensaje = '';
            }),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formulario,
            child: _tipo == _TipoReporte.fechas
                ? Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _desde,
                          readOnly: true,
                          onTap: () => _elegirFecha(_desde),
                          decoration: const InputDecoration(labelText: 'Desde'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hasta,
                          readOnly: true,
                          onTap: () => _elegirFecha(_hasta),
                          decoration: const InputDecoration(labelText: 'Hasta', errorMaxLines: 3),
                          validator: _validarHasta,
                        ),
                      ),
                    ],
                  )
                : TextFormField(
                    controller: _lugar,
                    decoration: const InputDecoration(
                      labelText: 'Lugar (o parte del nombre)',
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
          if (reporte != null && reporte.cantidad > 0) ...[
            const SizedBox(height: 16),
            Card(
              color: AppColors.azulClaro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos encontrados: ${reporte.cantidad}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul),
                    ),
                    const SizedBox(height: 6),
                    Text('Total sin IVA: ${Formato.dinero(reporte.totalSinIva)}'),
                    Text('Total IVA: ${Formato.dinero(reporte.totalIva)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Total con IVA: ${Formato.dinero(reporte.totalConIva)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.verde,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final gasto in reporte.gastos) FilaGasto(gasto: gasto, mostrarUsuario: _veTodos),
          ],
        ],
      ),
    );
  }
}
