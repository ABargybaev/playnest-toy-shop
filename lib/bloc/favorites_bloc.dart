import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/toy.dart';

class FavoriteToggled {
  final Toy toy;
  const FavoriteToggled(this.toy);
}
class FavoritesState extends Equatable {
  final Map<int, Toy> items;
  const FavoritesState({this.items = const {}});
  bool contains(int id) => items.containsKey(id);
  List<Toy> get toys => items.values.toList();
  @override
  List<Object?> get props => [items];
}
class FavoritesBloc extends Bloc<FavoriteToggled, FavoritesState> {
  FavoritesBloc() : super(const FavoritesState()) {
    on<FavoriteToggled>((event, emit) {
      final next = Map<int, Toy>.from(state.items);
      if (next.containsKey(event.toy.id)) {
        next.remove(event.toy.id);
      } else {
        next[event.toy.id] = event.toy;
      }
      emit(FavoritesState(items: Map.unmodifiable(next)));
    });
  }
}
