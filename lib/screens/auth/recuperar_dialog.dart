import 'package:material_ui/material_ui.dart';

import '../../utils/validaciones.dart';

/// Abre el diálogo "Recuperar contraseña".
/// Devuelve el correo escrito, o null si el usuario tocó Cancelar.
Future<String?> mostrarDialogoRecuperar(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _DialogoRecuperar(),
  );
}

class _DialogoRecuperar extends StatefulWidget {
  const _DialogoRecuperar();

  @override
  State<_DialogoRecuperar> createState() => _DialogoRecuperarState();
}

class _DialogoRecuperarState extends State<_DialogoRecuperar> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  /// Si el correo es inválido, el diálogo no se cierra y muestra el error.
  void _enviar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.of(context).pop(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Form(
        key: _formulario,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escribe el correo de tu cuenta y te enviaremos una contraseña temporal.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onFieldSubmitted: (_) => _enviar(),
              validator: Validaciones.email,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _enviar, child: const Text('Enviar')),
      ],
    );
  }
}
