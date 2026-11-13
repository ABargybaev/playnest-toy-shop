import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/catalog_bloc.dart';
import '../data/toy.dart';
import '../theme.dart';
import '../widgets/empty_panel.dart';
import '../widgets/toy_card.dart';

class CatalogPage extends StatefulWidget {
  final ValueChanged<Toy> onOpen;
  final ValueChanged<Toy> onFavorite;
  final ValueChanged<Toy> onAdd;
  const CatalogPage({super.key, required this.onOpen, required this.onFavorite,
    required this.onAdd});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final catalog = context.read<CatalogBloc>();
    catalog.add(const CatalogRequested());
    await catalog.stream.firstWhere((state) =>
        state.status == CatalogStatus.success ||
        state.status == CatalogStatus.failure);
  }

  String _sortLabel(ToySort sort) {
    switch (sort) {
      case ToySort.featured: return 'Популярные';
      case ToySort.priceLow: return 'Дешевле';
      case ToySort.priceHigh: return 'Дороже';
      case ToySort.rating: return 'По рейтингу';
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogBloc, CatalogState>(
    builder: (context, state) {
      final catalog = context.read<CatalogBloc>();
      return RefreshIndicator(
        onRefresh: _refresh,
        color: PlayColors.purple,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: const Color(0xFFE7FAF5), borderRadius: BorderRadius.circular(100)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.circle, color: PlayColors.mint, size: 9),
                      const SizedBox(width: 7),
                      Text(state.status == CatalogStatus.success ? 'Игрушки с онлайн API' : 'Магазин игрушек',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF358D82))),
                    ]),
                  ),
                  const Spacer(),
                  const Icon(Icons.auto_awesome_rounded, size: 21, color: PlayColors.pink),
                ]),
                const SizedBox(height: 16),
                const Text('Выбирайте радость\nкаждый день!',
                  style: TextStyle(fontSize: 29, height: 1.12,
                    fontWeight: FontWeight.w900, letterSpacing: -0.9, color: PlayColors.ink)),
                const SizedBox(height: 9),
                const Text('Яркие находки для маленьких мечтателей ✨',
                  style: TextStyle(color: PlayColors.muted, fontSize: 13.5)),
                const SizedBox(height: 18),
                _HeroBanner(onShow: () {
                  _search.clear();
                  catalog
                    ..add(const CatalogSearchChanged(''))
                    ..add(const CatalogCategoryChanged(null));
                }),
                const SizedBox(height: 18),
                TextField(
                  key: const Key('toy-search'),
                  controller: _search,
                  onChanged: (query) => catalog.add(CatalogSearchChanged(query)),
                  decoration: InputDecoration(
                    hintText: 'Найти игрушку, ID или SKU...',
                    hintStyle: const TextStyle(fontSize: 13, color: PlayColors.muted),
                    prefixIcon: const Icon(Icons.search_rounded, color: PlayColors.purple),
                    suffixIcon: state.query.isEmpty ? null : IconButton(
                      tooltip: 'Очистить',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _search.clear();
                        catalog.add(const CatalogSearchChanged(''));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 23),
                const Text('Категории', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: PlayColors.ink)),
                const SizedBox(height: 10),
              ]),
            )),
            SliverToBoxAdapter(child: SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _CategoryChip(label: 'Все игрушки', emoji: '✨', selected: state.category == null,
                    onTap: () => catalog.add(const CatalogCategoryChanged(null))),
                  ...state.categories.map((name) => _CategoryChip(
                    label: name, emoji: _emojiForCategory(name),
                    selected: state.category == name,
                    onTap: () => catalog.add(CatalogCategoryChanged(name)),
                  )),
                ],
              ),
            )),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 27, 15, 13),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Наши игрушки', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                    color: PlayColors.ink)),
                  const SizedBox(height: 3),
                  Text('${state.filtered.length} находок для радости',
                    style: const TextStyle(color: PlayColors.muted, fontSize: 12)),
                ]),
                const Spacer(),
                PopupMenuButton<ToySort>(
                  tooltip: 'Сортировка',
                  onSelected: (sort) => catalog.add(CatalogSortChanged(sort)),
                  itemBuilder: (_) => ToySort.values.map((sort) =>
                    PopupMenuItem(value: sort, child: Text(_sortLabel(sort)))).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.tune_rounded, color: PlayColors.purple, size: 17),
                      const SizedBox(width: 6),
                      Text(_sortLabel(state.sort), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    ]),
                  ),
                ),
              ]),
            )),
            if (state.status == CatalogStatus.loading && state.toys.isEmpty ||
                state.status == CatalogStatus.initial)
              const SliverFillRemaining(hasScrollBody: false,
                child: Center(child: Padding(padding: EdgeInsets.all(36),
                  child: CircularProgressIndicator(color: PlayColors.purple)))),
            if (state.status == CatalogStatus.failure)
              SliverFillRemaining(hasScrollBody: false, child: EmptyPanel(
                emoji: '📡', title: 'Не удалось загрузить игрушки',
                description: state.message ?? 'Не получилось связаться с сервером.',
                button: 'Повторить запрос',
                onPressed: () => catalog.add(const CatalogRequested()),
              )),
            if (state.status == CatalogStatus.success && state.filtered.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: EmptyPanel(
                emoji: '🔎', title: 'Пока ничего не нашли',
                description: 'Попробуйте другое название или сбросьте фильтры.',
                button: 'Показать все', onPressed: () {
                  _search.clear();
                  catalog
                    ..add(const CatalogSearchChanged(''))
                    ..add(const CatalogCategoryChanged(null));
                },
              )),
            if ((state.status == CatalogStatus.success ||
                  state.status == CatalogStatus.loading) && state.filtered.isNotEmpty)
              SliverToBoxAdapter(child: ToyGrid(
                toys: state.filtered,
                onOpen: widget.onOpen,
                onFavorite: widget.onFavorite,
                onAdd: widget.onAdd,
              )),
          ],
        ),
      );
    },
  );
}

String _emojiForCategory(String name) {
  switch (name) {
    case 'Мягкие': return '🧸';
    case 'Головоломки': return '🧩';
    case 'Конструкторы': return '🧱';
    case 'Транспорт': return '🚗';
    case 'Фигурки': return '🪆';
    case 'Развивающие': return '🤖';
    default: return '🎲';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.emoji,
    required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Material(
      color: selected ? PlayColors.purple : Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(
              color: selected ? Colors.white : PlayColors.ink,
              fontWeight: FontWeight.w800, fontSize: 12)),
          ]),
        ),
      ),
    ),
  );
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onShow;
  const _HeroBanner({required this.onShow});
  @override
  Widget build(BuildContext context) => Container(
    height: 162,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7362D9), Color(0xFFA77DEE)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(27),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: Stack(children: [
        Positioned(right: -38, top: -62,
          child: Container(width: 220, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10)))),
        Positioned(right: 29, bottom: -10,
          child: Transform.rotate(angle: -0.12, child: const Text('🧸', style: TextStyle(fontSize: 114)))),
        Positioned(right: 12, top: 12,
          child: const Icon(Icons.auto_awesome_rounded, size: 26, color: Color(0xFFFFE1A1))),
        Positioned(left: 20, top: 20, bottom: 19,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NEW COLLECTION', style: TextStyle(color: Color(0xFFFFD9A7),
              fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
            const SizedBox(height: 7),
            const Text('Море улыбок\nв одной коробке', style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900, height: 1.18)),
            const Spacer(),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: onShow,
                borderRadius: BorderRadius.circular(13),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Смотреть игрушки', style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w900, color: PlayColors.purple)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: PlayColors.purple),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    ),
  );
}
