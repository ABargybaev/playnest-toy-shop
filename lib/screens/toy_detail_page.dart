import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/favorites_bloc.dart';
import '../bloc/toy_detail_bloc.dart';
import '../data/toy.dart';
import '../theme.dart';
import '../widgets/empty_panel.dart';
import '../widgets/toy_art.dart';

class ToyDetailPage extends StatelessWidget {
  final int toyId;
  final ValueChanged<Toy> onFavorite;
  final ValueChanged<Toy> onAdd;
  const ToyDetailPage({super.key, required this.toyId,
    required this.onFavorite, required this.onAdd});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Игрушка #$toyId', style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w900)),
    ),
    body: BlocBuilder<ToyDetailBloc, ToyDetailState>(builder: (context, state) {
      if (state is ToyDetailLoading || state is ToyDetailInitial) {
        return const Center(child: CircularProgressIndicator(color: PlayColors.purple));
      }
      if (state is ToyDetailError) {
        return EmptyPanel(
          emoji: '🛠️', title: 'Не удалось открыть игрушку',
          description: state.message, button: 'Повторить',
          onPressed: () => context.read<ToyDetailBloc>().add(ToyDetailRequested(toyId)),
        );
      }
      final toy = (state as ToyDetailLoaded).toy;
      return LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 780;
        final artwork = SizedBox(
          height: wide ? 410 : 310,
          child: ToyArt(toy: toy, showId: true),
        );
        final info = _ToyInfo(toy: toy, onAdd: onAdd, onFavorite: onFavorite);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: artwork),
                    const SizedBox(width: 34),
                    Expanded(child: info),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    artwork,
                    const SizedBox(height: 26),
                    info,
                  ]),
          )),
        );
      });
    }),
  );
}

class _ToyInfo extends StatelessWidget {
  final Toy toy;
  final ValueChanged<Toy> onFavorite;
  final ValueChanged<Toy> onAdd;
  const _ToyInfo({required this.toy, required this.onFavorite, required this.onAdd});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: PlayColors.paleViolet,
          borderRadius: BorderRadius.circular(20)),
        child: Text(toy.category.toUpperCase(), style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w900, color: PlayColors.purple, letterSpacing: 0.7)),
      ),
      const SizedBox(height: 14),
      Text(toy.name, style: const TextStyle(fontSize: 27,
        fontWeight: FontWeight.w900, height: 1.15, color: PlayColors.ink)),
      const SizedBox(height: 15),
      Row(children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFFB955), size: 21),
        const SizedBox(width: 5),
        Text(toy.rating.toStringAsFixed(1), style: const TextStyle(
          fontWeight: FontWeight.w800, color: PlayColors.ink)),
        const SizedBox(width: 14),
        Icon(Icons.circle, size: 9,
          color: toy.inStock ? PlayColors.mint : PlayColors.pink),
        const SizedBox(width: 6),
        Text(toy.inStock ? 'В наличии' : 'Нет в наличии',
          style: const TextStyle(color: PlayColors.muted, fontSize: 12)),
      ]),
      const SizedBox(height: 20),
      Text(toy.formattedPrice, style: const TextStyle(color: PlayColors.purple,
        fontSize: 31, fontWeight: FontWeight.w900)),
      const SizedBox(height: 22),
      const Text('Об игрушке', style: TextStyle(
        fontWeight: FontWeight.w900, fontSize: 17, color: PlayColors.ink)),
      const SizedBox(height: 9),
      Text(toy.description.isEmpty ? 'Яркая находка из каталога игрушек.' : toy.description,
        style: const TextStyle(color: PlayColors.muted, fontSize: 14, height: 1.55)),
      const SizedBox(height: 23),
      Wrap(spacing: 9, runSpacing: 9, children: [
        _Tag(icon: Icons.tag_rounded, label: 'ID: ${toy.id}'),
        _Tag(icon: Icons.qr_code_rounded, label: toy.sku.isEmpty ? 'Toy SKU' : toy.sku),
        const _Tag(icon: Icons.cloud_done_rounded, label: 'Данные с API'),
      ]),
      const SizedBox(height: 27),
      Row(children: [
        Expanded(child: FilledButton.icon(
          onPressed: toy.inStock ? () => onAdd(toy) : null,
          icon: const Icon(Icons.shopping_bag_rounded),
          label: Text(toy.inStock ? 'В корзину' : 'Нет в наличии'),
          style: FilledButton.styleFrom(
            backgroundColor: PlayColors.purple,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
          ),
        )),
        const SizedBox(width: 10),
        BlocBuilder<FavoritesBloc, FavoritesState>(builder: (context, favorites) {
          final chosen = favorites.contains(toy.id);
          return OutlinedButton(
            onPressed: () => onFavorite(toy),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(58, 57),
              side: const BorderSide(color: Color(0xFFE9E5F4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
            ),
            child: Icon(chosen ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: chosen ? PlayColors.pink : PlayColors.purple),
          );
        }),
      ]),
      const SizedBox(height: 14),
      const Text('Учебный проект: реальные заказы и оплата не выполняются.',
        style: TextStyle(color: PlayColors.muted, fontSize: 11)),
    ],
  );
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: PlayColors.purple, size: 15),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700,
        color: PlayColors.ink, fontSize: 11)),
    ]),
  );
}
