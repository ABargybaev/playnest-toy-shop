import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../data/toy.dart';
import '../theme.dart';
import 'toy_art.dart';

class ToyCard extends StatelessWidget {
  final Toy toy;
  final ValueChanged<Toy> onOpen;
  final ValueChanged<Toy> onFavorite;
  final ValueChanged<Toy> onAdd;

  const ToyCard({
    super.key,
    required this.toy,
    required this.onOpen,
    required this.onFavorite,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onOpen(toy),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1EFF9)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: Stack(children: [
              Positioned.fill(child: ToyArt(toy: toy)),
              Positioned(top: 8, right: 8, child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) => Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(7),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: state.contains(toy.id) ? 'Убрать из избранного' : 'В избранное',
                    onPressed: () => onFavorite(toy),
                    icon: Icon(state.contains(toy.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: state.contains(toy.id) ? PlayColors.pink : PlayColors.ink),
                  ),
                ),
              )),
              if (!toy.inStock)
                Positioned(left: 8, bottom: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Нет в наличии', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10)),
                )),
            ])),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(
              toy.category.toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: PlayColors.purple),
            )),
            const SizedBox(height: 5),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(
              toy.name,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.18, color: PlayColors.ink),
            )),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(left: 3), child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFBA56), size: 16),
                const SizedBox(width: 3),
                Text(toy.rating.toStringAsFixed(1), style: const TextStyle(color: PlayColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('#${toy.id}', style: const TextStyle(color: PlayColors.muted, fontSize: 10)),
              ],
            )),
            const SizedBox(height: 7),
            Row(children: [
              Expanded(child: Text(toy.formattedPrice,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: PlayColors.ink, fontWeight: FontWeight.w900, fontSize: 17))),
              const SizedBox(width: 4),
              Material(
                color: toy.inStock ? PlayColors.purple : const Color(0xFFE4E1EA),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: toy.inStock ? () => onAdd(toy) : null,
                  child: const SizedBox(width: 40, height: 39,
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 24)),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

class ToyGrid extends StatelessWidget {
  final List<Toy> toys;
  final ValueChanged<Toy> onOpen;
  final ValueChanged<Toy> onFavorite;
  final ValueChanged<Toy> onAdd;
  final EdgeInsets padding;

  const ToyGrid({super.key, required this.toys, required this.onOpen,
    required this.onFavorite, required this.onAdd,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24)});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final count = width >= 1180 ? 5 : width >= 860 ? 4 : width >= 580 ? 3 : 2;
    return GridView.builder(
      padding: padding,
      itemCount: toys.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        mainAxisExtent: width < 370 ? 278 : 290,
      ),
      itemBuilder: (context, index) => ToyCard(
        toy: toys[index], onOpen: onOpen, onAdd: onAdd, onFavorite: onFavorite,
      ),
    );
  });
}
