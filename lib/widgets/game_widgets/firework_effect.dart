import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/game_utils/game_colors.dart';

/// Hiệu ứng pháo hoa khi thắng
class FireworkEffect extends StatefulWidget {
  const FireworkEffect({super.key});

  @override
  State<FireworkEffect> createState() => _FireworkEffectState();
}

class _FireworkEffectState extends State<FireworkEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _updateParticles();
            });
          });

    _generateParticles();
    _controller.forward();
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: 0.5,
          velocityX: (_random.nextDouble() - 0.5) * 2,
          velocityY: -_random.nextDouble() * 2 - 1,
          color: [
            GameColors.neonYellow,
            GameColors.neonPink,
            GameColors.neonCyan,
            GameColors.neonGreen,
          ][_random.nextInt(4)],
        ),
      );
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.velocityX * 0.02;
      particle.y += particle.velocityY * 0.02;
      particle.velocityY += 0.05; // Gravity
      particle.opacity *= 0.95; // Fade out
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: FireworkPainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  Color color;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    this.opacity = 1.0,
  });
}

class FireworkPainter extends CustomPainter {
  final List<Particle> particles;

  FireworkPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.opacity > 0.1) {
        final paint = Paint()
          ..color = particle.color.withOpacity(particle.opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(particle.x * size.width, particle.y * size.height),
          5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FireworkPainter oldDelegate) => true;
}
