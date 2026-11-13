import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/toy.dart';
import '../data/toy_api.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}
class CatalogRequested extends CatalogEvent { const CatalogRequested(); }
class CatalogSearchChanged extends CatalogEvent {
  final String query;
  const CatalogSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
class CatalogCategoryChanged extends CatalogEvent {
  final String? category;
  const CatalogCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}
class CatalogSortChanged extends CatalogEvent {
  final ToySort sort;
  const CatalogSortChanged(this.sort);
  @override
  List<Object?> get props => [sort];
}

enum CatalogStatus { initial, loading, success, failure }
enum ToySort { featured, priceLow, priceHigh, rating }

class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<Toy> toys;
  final String query;
  final String? category;
  final ToySort sort;
  final String? message;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.toys = const [],
    this.query = '',
    this.category,
    this.sort = ToySort.featured,
    this.message,
  });

  CatalogState copyWith({
    CatalogStatus? status,
    List<Toy>? toys,
    String? query,
    String? category,
    bool clearCategory = false,
    ToySort? sort,
    String? message,
    bool clearMessage = false,
  }) => CatalogState(
    status: status ?? this.status,
    toys: toys ?? this.toys,
    query: query ?? this.query,
    category: clearCategory ? null : (category ?? this.category),
    sort: sort ?? this.sort,
    message: clearMessage ? null : (message ?? this.message),
  );

  List<String> get categories {
    const order = ['Мягкие', 'Конструкторы', 'Головоломки', 'Транспорт', 'Фигурки', 'Развивающие', 'Другие'];
    return order.where((name) => toys.any((toy) => toy.category == name)).toList();
  }

  List<Toy> get filtered {
    final needle = query.trim().toLowerCase();
    final found = toys.where((toy) {
      final catMatches = category == null || toy.category == category;
      final textMatches = needle.isEmpty ||
          toy.name.toLowerCase().contains(needle) ||
          toy.description.toLowerCase().contains(needle) ||
          toy.sku.toLowerCase().contains(needle) ||
          toy.id.toString() == needle;
      return catMatches && textMatches;
    }).toList();
    switch (sort) {
      case ToySort.featured:
        break;
      case ToySort.priceLow:
        found.sort((a, b) => a.price.compareTo(b.price));
      case ToySort.priceHigh:
        found.sort((a, b) => b.price.compareTo(a.price));
      case ToySort.rating:
        found.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return found;
  }

  @override
  List<Object?> get props => [status, toys, query, category, sort, message];
}

/// BLoC holds screen state; data repository does the real async HTTP GET.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ToyApi repository;
  CatalogBloc(this.repository) : super(const CatalogState()) {
    on<CatalogRequested>(_load);
    on<CatalogSearchChanged>((event, emit) => emit(state.copyWith(query: event.query)));
    on<CatalogCategoryChanged>((event, emit) => emit(state.copyWith(
      category: event.category,
      clearCategory: event.category == null,
    )));
    on<CatalogSortChanged>((event, emit) => emit(state.copyWith(sort: event.sort)));
  }

  Future<void> _load(CatalogRequested event, Emitter<CatalogState> emit) async {
    emit(state.copyWith(status: CatalogStatus.loading, clearMessage: true));
    try {
      final toys = await repository.getToys();
      if (emit.isDone) return;
      emit(state.copyWith(
        status: CatalogStatus.success,
        toys: toys,
        clearMessage: true,
      ));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(status: CatalogStatus.failure, message: '$error'));
    }
  }
}
