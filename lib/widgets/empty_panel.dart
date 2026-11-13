import 'package:flutter/material.dart';
import '../theme.dart';

class EmptyPanel extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String button;
  final VoidCallback onPressed;

  const EmptyPanel({super.key, required this.emoji, required this.title,
    required this.description, required this.button, required this.onPressed});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 124, height: 124,
            decoration: const BoxDecoration(color: PlayColors.paleViolet, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 62)),
          ),
          const SizedBox(height: 23),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w900, color: PlayColors.ink)),
          const SizedBox(height: 9),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(
            color: PlayColors.muted, fontSize: 14, height: 1.45)),
          const SizedBox(height: 23),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(button),
            style: FilledButton.styleFrom(
              backgroundColor: PlayColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            ),
          ),
        ]),
      ),
    ),
  );
}
