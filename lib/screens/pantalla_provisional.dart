import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'splash_screen.dart';

/// Pantalla temporal de la Fase 1: muestra qué pasó en el splash.
/// En la Fase 2 se reemplaza por el login y el menú.
class PantallaProvisional extends StatelessWidget {
  const PantallaProvisional({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oye!')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/logo_oye.png', height: 120),
            const SizedBox(height: 24),
            Card(
              color: AppColors.ambarClaro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(estado, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
              ),
              child: const Text('Volver al splash'),
            ),
          ],
        ),
      ),
    );
  }
}
