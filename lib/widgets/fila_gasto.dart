import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../theme/app_colors.dart';
import '../utils/formato.dart';

/// Una fila de gasto (equivale a item_gasto.xml + GastoAdapter del Corte 3).
/// La usan la lista de gastos y el reporte de gastos.
class FilaGasto extends StatelessWidget {
  const FilaGasto({super.key, required this.gasto, required this.mostrarUsuario, this.alTocar});

  final Gasto gasto;
  final bool mostrarUsuario;
  final VoidCallback? alTocar; // null en los reportes: las filas solo se leen

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
