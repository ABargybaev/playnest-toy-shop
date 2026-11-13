import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/toy_detail_bloc.dart';
import '../data/toy.dart';
import '../data/toy_api.dart';
import '../theme.dart';
import 'cart_page.dart';
import 'catalog_page.dart';
import 'favorites_page.dart';
import 'toy_detail_page.dart';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});
  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  int _tab = 0;

  void _open(Toy toy) => _openById(toy.id);

  void _openById(int id) {
    final api = context.read<ToyApi>();
    Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => ToyDetailBloc(api)..add(ToyDetailRequested(id)),
        child: ToyDetailPage(toyId: id, onAdd: _addToCart, onFavorite: _toggleFavorite),
      ),
    ));
  }

  void _addToCart(Toy toy) {
    if (!toy.inStock) {
      _notify('Этой игрушки сейчас нет в наличии');
      return;
    }
    if ((context.read<CartBloc>().state.lines[toy.id]?.quantity ?? 0) >= 20) {
      _notify('Максимум 20 штук одной игрушки');
      return;
    }
    context.read<CartBloc>().add(CartToyAdded(toy));
    _notify('Добавлено в корзину 🛍️');
  }

  void _toggleFavorite(Toy toy) =>
      context.read<FavoritesBloc>().add(FavoriteToggled(toy));

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message),
        duration: const Duration(seconds: 2)));
  }

  Future<void> _searchById() async {
    final controller = TextEditingController();
    final id = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Поиск игрушки по ID'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ID игрушки', hintText: 'Например: 5',
            prefixIcon: Icon(Icons.tag_rounded)),
          onSubmitted: (text) {
            final value = int.tryParse(text.trim());
            if (value != null && value > 0) Navigator.pop(dialogContext, value);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Введите положительный ID')));
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Найти'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (mounted && id != null) _openById(id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 18,
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 37, height: 37,
          decoration: BoxDecoration(
            color: PlayColors.paleViolet,
            borderRadius: BorderRadius.circular(13)),
          alignment: Alignment.center,
          child: const Text('🧸', style: TextStyle(fontSize: 23)),
        ),
        const SizedBox(width: 9),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('playnest.', style: TextStyle(color: PlayColors.ink,
            fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: -0.6)),
          Text('TOY SHOP', style: TextStyle(color: PlayColors.muted,
            fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2.3)),
        ]),
      ]),
      actions: [
        IconButton(
          tooltip: 'Найти игрушку по ID',
          onPressed: _searchById,
          icon: const Icon(Icons.tag_rounded, color: PlayColors.ink)),
        IconButton(
          tooltip: 'Обновить с сервера',
          onPressed: () {
            setState(() => _tab = 0);
            context.read<CatalogBloc>().add(const CatalogRequested());
          },
          icon: const Icon(Icons.refresh_rounded, color: PlayColors.ink)),
        const SizedBox(width: 7),
      ],
    ),
    body: IndexedStack(index: _tab, children: [
      CatalogPage(onOpen: _open, onFavorite: _toggleFavorite, onAdd: _addToCart),
      FavoritesPage(onBrowse: () => setState(() => _tab = 0),
        onOpen: _open, onAdd: _addToCart, onFavorite: _toggleFavorite),
      CartPage(onBrowse: () => setState(() => _tab = 0)),
    ]),
    bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
      builder: (context, cart) => NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: PlayColors.paleViolet,
        height: 75,
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded, color: PlayColors.purple),
            label: 'Каталог'),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: PlayColors.pink),
            label: 'Избранное'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.count > 0,
              label: Text('${cart.count}'),
              child: const Icon(Icons.shopping_bag_outlined)),
            selectedIcon: Badge(
              isLabelVisible: cart.count > 0,
              label: Text('${cart.count}'),
              child: const Icon(Icons.shopping_bag_rounded, color: PlayColors.purple)),
            label: 'Корзина'),
        ],
      ),
    ),
  );
}
