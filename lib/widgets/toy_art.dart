import 'package:flutter/material.dart';
import '../data/toy.dart';
import '../theme.dart';

/// Self-contained artwork: no external image URLs or network image failures.
/// The actual toy names, price and stock always come from the REST API.
class ToyArt extends StatelessWidget {
  final Toy toy;
  final bool showId;
  const ToyArt({super.key, required this.toy, this.showId = false});

  static Color tintFor(Toy toy) {
    switch (toy.category) {
      case 'Мягкие': return const Color(0xFFFFE3EC);
      case 'Конструкторы': return const Color(0xFFFFF0CD);
      case 'Головоломки': return const Color(0xFFDDF7F0);
      case 'Транспорт': return const Color(0xFFE5ECFF);
      case 'Фигурки': return const Color(0xFFF0E3FF);
      case 'Развивающие': return const Color(0xFFD9F5FC);
      default:
        const palette = [Color(0xFFE6E2FF), Color(0xFFFFE7D5), Color(0xFFE3F4E5), Color(0xFFFFE4F0)];
        return palette[toy.id.abs() % palette.length];
    }
  }

  static String emojiFor(Toy toy) {
    switch (toy.category) {
      case 'Мягкие': return '🧸';
      case 'Конструкторы': return '🧱';
      case 'Головоломки': return '🧩';
      case 'Транспорт': return '🚂';
      case 'Фигурки': return '🪆';
      case 'Развивающие': return '🤖';
      default:
        const toys = ['🪀', '🪁', '🎲', '🦄', '🦖', '🎨', '🚀', '🐻'];
        return toys[toy.id.abs() % toys.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = tintFor(toy);
    return LayoutBuilder(builder: (context, constraints) {
      final minSide = constraints.biggest.shortestSide.isFinite
          ? constraints.biggest.shortestSide
          : 160.0;
      final emojiSize = (minSide * 0.49).clamp(52.0, 120.0).toDouble();
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [base, Color.lerp(base, Colors.white, 0.42)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(right: -22, top: -24, child: _Bubble(size: 105, opacity: 0.55)),
              Positioned(left: -29, bottom: -45, child: _Bubble(size: 112, opacity: 0.40)),
              Positioned(
                left: 17, top: 16,
                child: Icon(Icons.auto_awesome_rounded, color: PlayColors.purple.withValues(alpha: 0.40), size: 17),
              ),
              Positioned(
                right: 18, bottom: 15,
                child: Icon(Icons.star_rounded, color: PlayColors.pink.withValues(alpha: 0.70), size: 24),
              ),
              Center(child: Transform.rotate(
                angle: -0.10,
                child: Text(emojiFor(toy), textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: emojiSize,
                    shadows: [Shadow(color: PlayColors.ink.withValues(alpha: 0.12), offset: const Offset(0, 9), blurRadius: 20)],
                  ),
                ),
              )),
              if (showId)
                Positioned(
                  bottom: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.90), borderRadius: BorderRadius.circular(14)),
                    child: Text('#${toy.id}', style: const TextStyle(color: PlayColors.ink, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacity), shape: BoxShape.circle,
    ),
  );
}
