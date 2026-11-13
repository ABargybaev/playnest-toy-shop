import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/toy.dart';

abstract class CartEvent { const CartEvent(); }
class CartToyAdded extends CartEvent {
  final Toy toy;
  const CartToyAdded(this.toy);
}
class CartToyRemoved extends CartEvent {
  final int id;
  const CartToyRemoved(this.id);
}
class CartQuantityChanged extends CartEvent {
  final int id;
  final int delta;
  const CartQuantityChanged(this.id, this.delta);
}
class CartCleared extends CartEvent { const CartCleared(); }

class CartLine {
  final Toy toy;
  final int quantity;
  const CartLine(this.toy, this.quantity);
  double get total => toy.price * quantity;
}
class CartState extends Equatable {
  final Map<int, CartLine> lines;
  const CartState({this.lines = const {}});
  int get count => lines.values.fold(0, (acc, line) => acc + line.quantity);
  double get total => lines.values.fold(0.0, (acc, line) => acc + line.total);
  @override
  List<Object?> get props => [lines];
}

/// In-memory demo cart. No real payments or server checkout.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartToyAdded>((event, emit) {
      if (!event.toy.inStock) return;
      final next = Map<int, CartLine>.from(state.lines);
      final amount = next[event.toy.id]?.quantity ?? 0;
      if (amount >= 20) return;
      next[event.toy.id] = CartLine(event.toy, amount + 1);
      emit(CartState(lines: Map.unmodifiable(next)));
    });
    on<CartToyRemoved>((event, emit) {
      if (!state.lines.containsKey(event.id)) return;
      final next = Map<int, CartLine>.from(state.lines)..remove(event.id);
      emit(CartState(lines: Map.unmodifiable(next)));
    });
    on<CartQuantityChanged>((event, emit) {
      final line = state.lines[event.id];
      if (line == null) return;
      final amount = line.quantity + event.delta;
      if (amount > 20) return;
      final next = Map<int, CartLine>.from(state.lines);
      if (amount <= 0) {
        next.remove(event.id);
      } else {
        next[event.id] = CartLine(line.toy, amount);
      }
      emit(CartState(lines: Map.unmodifiable(next)));
    });
    on<CartCleared>((event, emit) => emit(const CartState()));
  }
}
