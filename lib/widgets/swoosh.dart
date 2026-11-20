import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Trazo ámbar bajo "¡Empieza hoy!", como en el banner de la marca.
/// En el Corte 3 era el vector ic_swoosh.xml; aquí se dibuja con CustomPaint.
class Swoosh extends StatelessWidget {
  const Swoosh({super.key, this.ancho = 160});

  final double ancho;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(ancho, ancho * 24 / 200),
      painter: _SwooshPainter(),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Mismo trazo que el vector: M6,18 Q100,2 194,12 en un lienzo de 200 x 24.
    final escalaX = size.width / 200;
    final escalaY = size.height / 24;
    final trazo = Path()
      ..moveTo(6 * escalaX, 18 * escalaY)
      ..quadraticBezierTo(100 * escalaX, 2 * escalaY, 194 * escalaX, 12 * escalaY);
    final pincel = Paint()
      ..color = AppColors.ambar
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * escalaX
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(trazo, pincel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
