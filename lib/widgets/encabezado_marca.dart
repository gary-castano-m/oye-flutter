import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Encabezado azul con las esquinas de abajo redondeadas y el logo blanco.
/// Es el fondo_encabezado.xml del Corte 3, usado en el login y en el menú.
class EncabezadoMarca extends StatelessWidget {
  const EncabezadoMarca({super.key, this.children = const [], this.alturaLogo = 80});

  /// Lo que va debajo del logo: el lema en el login, el saludo en el menú.
  final List<Widget> children;
  final double alturaLogo;

  @override
  Widget build(BuildContext context) {
    // Se suma el alto de la barra de estado para que el azul llegue hasta arriba.
    final margenSuperior = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, margenSuperior + 20, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.azul,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo_oye_blanco.png',
            height: alturaLogo,
            semanticLabel: 'Logo de Oye!',
          ),
          ...children,
        ],
      ),
    );
  }
}
