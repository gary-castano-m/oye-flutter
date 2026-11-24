import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../sensors/ubicacion_service.dart';
import '../../services/api_exception.dart';
import '../../services/gasto_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formato.dart';
import '../../utils/validaciones.dart';
import '../../widgets/mensaje_estado.dart';

/// Formulario para crear o editar un gasto (equivale a GastoFormActivity del Corte 3
/// y a Screen6 de Kodular).
/// - Sin gastoId: crea con POST /api/gastos.
/// - Con gastoId: carga el gasto con GET /api/gastos/{id} y guarda con PUT.
/// El IVA que se ve aquí es solo una vista previa: el valor oficial lo calcula la API.
/// Sensor de ubicación: en un gasto nuevo llena "Lugar" solo (si está vacío);
/// el ícono del campo vuelve a pedir la ubicación cuando se quiera.
class GastoFormScreen extends StatefulWidget {
  const GastoFormScreen({super.key, this.gastoId});

  final String? gastoId; // null = gasto nuevo

  @override
  State<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends State<GastoFormScreen> {
  static const double tasaIvaVistaPrevia = 0.19;

  final _formulario = GlobalKey<FormState>();
  final _fecha = TextEditingController();
  final _valor = TextEditingController();
  final _lugar = TextEditingController();
  final _descripcion = TextEditingController();

  final GastoService _gastos = GastoService();
  final UbicacionService _ubicacion = UbicacionService();

  bool _cargando = false;
  bool _puedeGuardar = true;
  bool _buscandoUbicacion = false;
  String? _ayudaLugar;
  String _estado = '';
  bool _estadoEsError = false;

  bool get _esNuevo => widget.gastoId == null;

  @override
  void initState() {
    super.initState();
    // Cada vez que cambia el valor, se recalcula la vista previa del IVA.
    _valor.addListener(() => setState(() {}));
    if (_esNuevo) _fecha.text = Formato.fechaIso(DateTime.now());

    // setState no se puede usar dentro de initState: se espera a que la pantalla
    // se dibuje por primera vez y luego se arranca.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_esNuevo) {
        _usarUbicacion(reemplazar: false); // en un gasto nuevo se intenta llenar el lugar solo
      } else {
        _cargarGasto();
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_fecha, _valor, _lugar, _descripcion]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Cargar (solo al editar) ----------

  Future<void> _cargarGasto() async {
    _mostrarCargando(true);
    try {
      final gasto = await _gastos.consultar(widget.gastoId!);
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _estado = '';
        _fecha.text = gasto.fecha;
        _valor.text = _sinCerosSobrantes(gasto.valorTotalSinIva);
        _lugar.text = gasto.lugar;
        _descripcion.text = gasto.descripcion;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _puedeGuardar = false;
        _estado = e.mensaje;
        _estadoEsError = true;
      });
    }
  }

  // ---------- Guardar ----------

  Future<void> _guardar() async {
    setState(() => _estado = '');
    if (!_formulario.currentState!.validate()) return;

    final valor = Formato.leerValor(_valor.text)!;
    final fecha = _fecha.text.trim();
    final lugar = _lugar.text.trim();
    final descripcion = _descripcion.text.trim();

    _mostrarCargando(true);
    try {
      final gasto = _esNuevo
          ? await _gastos.registrar(
              fecha: fecha, valorSinIva: valor, lugar: lugar, descripcion: descripcion)
          : await _gastos.actualizar(widget.gastoId!,
              fecha: fecha, valorSinIva: valor, lugar: lugar, descripcion: descripcion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gasto guardado. Total: ${Formato.dinero(gasto.valorTotalConIva)}')),
      );
      Navigator.of(context).pop(true); // true = hubo cambios, la lista se recarga
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _estado = e.mensaje;
        _estadoEsError = true;
      });
    }
  }

  // ---------- Sensor de ubicación ----------

  /// [reemplazar] es true cuando la persona toca el ícono y quiere cambiar lo escrito.
  Future<void> _usarUbicacion({required bool reemplazar}) async {
    setState(() {
      _buscandoUbicacion = true;
      _ayudaLugar = 'Buscando tu ubicación…';
    });
    try {
      final lugar = await _ubicacion.obtenerLugar();
      if (!mounted) return;
      setState(() {
        // Igual que en Kodular y en el Corte 3: no se borra lo que la persona ya escribió.
        if (reemplazar || _lugar.text.trim().isEmpty) _lugar.text = lugar;
        _ayudaLugar = 'Lugar tomado de tu ubicación. Puedes corregirlo.';
      });
    } on UbicacionException catch (e) {
      if (!mounted) return;
      setState(() => _ayudaLugar = e.mensaje);
    } finally {
      if (mounted) setState(() => _buscandoUbicacion = false);
    }
  }

  // ---------- Fecha ----------

  Future<void> _elegirFecha() async {
    final actual = Formato.leerFechaIso(_fecha.text) ?? DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha del gasto',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null) setState(() => _fecha.text = Formato.fechaIso(elegida));
  }

  // ---------- Utilidades ----------

  void _mostrarCargando(bool cargando) {
    setState(() {
      _cargando = cargando;
      if (cargando) {
        _estado = 'Conectando con el servidor… la primera vez puede tardar hasta un minuto.';
        _estadoEsError = false;
      }
    });
  }

  /// 10000.0 → "10000"   ·   10000.5 → "10000.5"
  static String _sinCerosSobrantes(double valor) =>
      valor == valor.roundToDouble() ? valor.toStringAsFixed(0) : valor.toString();

  static String? _validarValor(String? texto) {
    final valor = Formato.leerValor(texto ?? '');
    if (valor == null || valor < 0) return 'Escribe un valor válido (0 o más).';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Vista previa del IVA: solo informativa.
    final valor = Formato.leerValor(_valor.text) ?? 0;
    final iva = (valor * tasaIvaVistaPrevia * 100).round() / 100;
    final bloqueado = _cargando || !_puedeGuardar;

    return Scaffold(
      appBar: AppBar(title: Text(_esNuevo ? 'Registrar gasto' : 'Editar gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fecha,
                readOnly: true, // se elige con el calendario, no se escribe
                enabled: !bloqueado,
                onTap: _elegirFecha,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: Validaciones.obligatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valor,
                enabled: !bloqueado,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(
                  labelText: 'Valor sin IVA',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: _validarValor,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lugar,
                enabled: !bloqueado,
                maxLength: UbicacionService.largoMaximoLugar,
                decoration: InputDecoration(
                  labelText: 'Lugar',
                  prefixIcon: const Icon(Icons.place_outlined),
                  helperText: _ayudaLugar,
                  helperMaxLines: 2,
                  suffixIcon: _buscandoUbicacion
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Usar mi ubicación',
                          icon: const Icon(Icons.my_location),
                          onPressed: bloqueado ? null : () => _usarUbicacion(reemplazar: true),
                        ),
                ),
                validator: Validaciones.obligatorio,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcion,
                enabled: !bloqueado,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: Validaciones.obligatorio,
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.azulClaro,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IVA (19 %): ${Formato.dinero(iva)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Total con IVA: ${Formato.dinero(valor + iva)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Vista previa. El valor oficial del IVA lo calcula el servidor.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: bloqueado ? null : _guardar,
                child: const Text('Guardar gasto'),
              ),
              if (_cargando) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              MensajeEstado(texto: _estado, esError: _estadoEsError),
            ],
          ),
        ),
      ),
    );
  }
}
