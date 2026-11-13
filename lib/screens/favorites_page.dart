import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/favorites_bloc.dart';
import '../data/toy.dart';
import '../theme.dart';
import '../widgets/empty_panel.dart';
import '../widgets/toy_card.dart';

class FavoritesPage extends StatelessWidget {
  final VoidCallback onBrowse;
  final ValueChanged<Toy> onOpen;
  final ValueChanged<Toy> onAdd;
  final ValueChanged<Toy> onFavorite;

  const FavoritesPage({super.key, required this.onBrowse,
    required this.onOpen, required this.onAdd, required this.onFavorite});

  @override
  Widget build(BuildContext context) => BlocBuilder<FavoritesBloc, FavoritesState>(
    builder: (context, state) {
      if (state.items.isEmpty) {
        return EmptyPanel(
          emoji: '💗', title: 'Здесь живут любимчики',
          description: 'Нажимайте на сердечко у понравившейся игрушки, чтобы сохранить её здесь.',
          button: 'Выбрать игрушки', onPressed: onBrowse,
        );
      }
      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 24, 19, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Любимые игрушки 💖', style: TextStyle(
                color: PlayColors.ink, fontWeight: FontWeight.w900, fontSize: 24)),
              const SizedBox(height: 7),
              Text('В избранном: ${state.toys.length}',
                style: const TextStyle(color: PlayColors.muted, fontSize: 13)),
              const SizedBox(height: 18),
            ]),
          ),
          ToyGrid(toys: state.toys, onOpen: onOpen, onFavorite: onFavorite, onAdd: onAdd),
        ]),
      );
    },
  );
}
