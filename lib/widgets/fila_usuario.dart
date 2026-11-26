import 'package:material_ui/material_ui.dart';

import '../models/usuario.dart';
import '../theme/app_colors.dart';
import '../utils/etiquetas.dart';

/// Una fila de usuario (equivale a item_usuario.xml + UsuarioAdapter del Corte 3).
/// La usan la lista de usuarios y el reporte de usuarios.
class FilaUsuario extends StatelessWidget {
  const FilaUsuario({super.key, required this.usuario, this.esYo = false, this.alTocar});

  final Usuario usuario;
  final bool esYo;
  final VoidCallback? alTocar; // null en los reportes

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
