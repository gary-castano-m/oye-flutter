import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Texto bajo los botones que informa qué está pasando: "Conectando…",
/// un error de la API o un aviso. Es el tvEstado del Corte 3.
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({super.key, required this.texto, this.esError = false});

  final String texto;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: esError ? Theme.of(context).colorScheme.error : AppColors.azul,
        ),
      ),
    );
  }
}
