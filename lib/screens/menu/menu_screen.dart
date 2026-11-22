import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/usuario.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/etiquetas.dart';
import '../../utils/navegacion.dart';
import '../../widgets/encabezado_marca.dart';

/// Menú principal (equivale a MenuActivity del Corte 3; une Screen4 y Screen5 de Kodular):
/// todos ven la sección de gastos y solo el ADMIN ve la sección de administración.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final SessionService _sesion = SessionService.instance;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  /// Lee el usuario guardado. Se vuelve a llamar al regresar de otra pantalla
  /// (por ejemplo, después de editar el nombre en Mi perfil).
  Future<void> _cargarUsuario() async {
    final usuario = await _sesion.leerUsuario();
    if (!mounted) return;
    if (usuario == null) {
      Navegacion.irAlLogin(context);
      return;
    }
    setState(() => _usuario = usuario);
  }

  /// Aviso temporal para las opciones que se construyen en las fases siguientes.
  void _proximamente(String opcion, int fase) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('"$opcion" llega en la Fase $fase.')));
  }

  Future<void> _confirmarCierreDeSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await _sesion.cerrarSesion();
    if (!mounted) return;
    Navegacion.irAlLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: usuario == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EncabezadoMarca(
                      alturaLogo: 64,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Hola, ${usuario.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.fuenteTitulos,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Rol: ${Etiquetas.rol(usuario.role)}',
                          style: const TextStyle(color: AppColors.ambar, fontSize: 16),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _TituloSeccion('Gastos'),
                          _BotonMenu(
                            texto: 'Registrar gasto',
                            icono: Icons.add_circle_outline,
                            alTocar: () => _proximamente('Registrar gasto', 3),
                          ),
                          _BotonMenu(
                            texto: 'Mis gastos',
                            icono: Icons.receipt_long,
                            alTocar: () => _proximamente('Mis gastos', 3),
                          ),
                          _BotonMenu(
                            texto: 'Reportes de gastos',
                            icono: Icons.bar_chart,
                            alTocar: () => _proximamente('Reportes de gastos', 5),
                          ),
                          // Solo el ADMIN ve esta sección.
                          if (usuario.esAdmin) ...[
                            const _TituloSeccion('Administración'),
                            _BotonMenu(
                              texto: 'Usuarios',
                              icono: Icons.group_outlined,
                              alTocar: () => _proximamente('Usuarios', 4),
                            ),
                            _BotonMenu(
                              texto: 'Reportes de usuarios',
                              icono: Icons.assessment_outlined,
                              alTocar: () => _proximamente('Reportes de usuarios', 5),
                            ),
                          ],
                          const _TituloSeccion('Mi cuenta'),
                          _BotonMenu(
                            texto: 'Mi perfil',
                            icono: Icons.person_outline,
                            alTocar: () => _proximamente('Mi perfil', 4),
                          ),
                          _BotonMenu(
                            texto: 'Cerrar sesión',
                            icono: Icons.logout,
                            alTocar: _confirmarCierreDeSesion,
                            secundario: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: AppTheme.fuenteTitulos,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.azul,
        ),
      ),
    );
  }
}

/// Botón ancho del menú con ícono. "secundario" lo pinta con borde en vez de relleno.
class _BotonMenu extends StatelessWidget {
  const _BotonMenu({
    required this.texto,
    required this.icono,
    required this.alTocar,
    this.secundario = false,
  });

  final String texto;
  final IconData icono;
  final VoidCallback alTocar;
  final bool secundario;

  @override
  Widget build(BuildContext context) {
    final contenido = Row(
      children: [
        Icon(icono),
        const SizedBox(width: 12),
        Text(texto),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: secundario
          ? OutlinedButton(
              onPressed: alTocar,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.azul,
                side: const BorderSide(color: AppColors.azul),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: contenido,
            )
          : ElevatedButton(onPressed: alTocar, child: contenido),
    );
  }
}
