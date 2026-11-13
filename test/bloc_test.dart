import 'package:flutter_test/flutter_test.dart';
import 'package:playnest_toys/bloc/cart_bloc.dart';
import 'package:playnest_toys/bloc/catalog_bloc.dart';
import 'package:playnest_toys/bloc/favorites_bloc.dart';
import 'package:playnest_toys/bloc/toy_detail_bloc.dart';
import 'package:playnest_toys/data/toy.dart';
import 'package:playnest_toys/data/toy_api.dart';

const teddy = Toy(id: 1, name: 'Cotton Teddy Bear', category: 'Мягкие',
  price: 20, rating: 4.8, sku: 'TOY-1');
const blocks = Toy(id: 2, name: 'Wood Building Blocks', category: 'Конструкторы',
  price: 30, rating: 4.3, sku: 'TOY-2');
const unavailable = Toy(id: 3, name: 'Robot Toy', price: 17, inStock: false);

class MockApi implements ToyApi {
  @override
  Future<List<Toy>> getToys() async => [teddy, blocks, unavailable];
  @override
  Future<Toy> getToyById(int id) async => [teddy, blocks, unavailable].firstWhere((t) => t.id == id);
}

void main() {
  test('catalog BLoC loads asynchronously, filters and sorts', () async {
    final bloc = CatalogBloc(MockApi());
    final loaded = bloc.stream.firstWhere((state) => state.status == CatalogStatus.success);
    bloc.add(const CatalogRequested());
    final state = await loaded;
    expect(state.toys, hasLength(3));
    expect(state.categories, contains('Конструкторы'));
    bloc.add(const CatalogSearchChanged('bear'));
    final searched = await bloc.stream.firstWhere((s) => s.query == 'bear');
    expect(searched.filtered.map((t) => t.id), [1]);
    bloc.add(const CatalogSearchChanged(''));
    await bloc.stream.firstWhere((s) => s.query.isEmpty);
    bloc.add(const CatalogSortChanged(ToySort.priceHigh));
    final sorted = await bloc.stream.firstWhere((s) => s.sort == ToySort.priceHigh);
    expect(sorted.filtered.first.id, 2);
    await bloc.close();
  });

  test('detail BLoC loads toy by ID using repository', () async {
    final bloc = ToyDetailBloc(MockApi());
    bloc.add(const ToyDetailRequested(2));
    final loaded = await bloc.stream.firstWhere((s) => s is ToyDetailLoaded);
    expect((loaded as ToyDetailLoaded).toy.name, blocks.name);
    await bloc.close();
  });

  test('favorites BLoC toggles and removes toys', () async {
    final bloc = FavoritesBloc();
    bloc.add(const FavoriteToggled(teddy));
    final added = await bloc.stream.firstWhere((s) => s.contains(1));
    expect(added.toys, [teddy]);
    bloc.add(const FavoriteToggled(teddy));
    final removed = await bloc.stream.firstWhere((s) => !s.contains(1));
    expect(removed.items, isEmpty);
    await bloc.close();
  });

  test('cart BLoC increments quantity and calculates total', () async {
    final bloc = CartBloc();
    bloc.add(const CartToyAdded(teddy));
    await bloc.stream.firstWhere((s) => s.count == 1);
    bloc.add(const CartToyAdded(teddy));
    final updated = await bloc.stream.firstWhere((s) => s.count == 2);
    expect(updated.total, 40);
    bloc.add(const CartQuantityChanged(1, -1));
    final decremented = await bloc.stream.firstWhere((s) => s.count == 1);
    expect(decremented.total, 20);
    bloc.add(const CartToyRemoved(1));
    final empty = await bloc.stream.firstWhere((s) => s.lines.isEmpty);
    expect(empty.count, 0);
    await bloc.close();
  });

  test('out-of-stock toy cannot be added to demo cart', () async {
    final bloc = CartBloc();
    bloc.add(const CartToyAdded(unavailable));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state.lines, isEmpty);
    await bloc.close();
  });
}
