import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/toy.dart';
import '../data/toy_api.dart';

class ToyDetailRequested {
  final int id;
  const ToyDetailRequested(this.id);
}
abstract class ToyDetailState extends Equatable {
  const ToyDetailState();
  @override
  List<Object?> get props => [];
}
class ToyDetailInitial extends ToyDetailState { const ToyDetailInitial(); }
class ToyDetailLoading extends ToyDetailState { const ToyDetailLoading(); }
class ToyDetailLoaded extends ToyDetailState {
  final Toy toy;
  const ToyDetailLoaded(this.toy);
  @override
  List<Object?> get props => [toy.id, toy.name, toy.price];
}
class ToyDetailError extends ToyDetailState {
  final String message;
  const ToyDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ToyDetailBloc extends Bloc<ToyDetailRequested, ToyDetailState> {
  final ToyApi repository;
  ToyDetailBloc(this.repository) : super(const ToyDetailInitial()) {
    on<ToyDetailRequested>((event, emit) async {
      emit(const ToyDetailLoading());
      try {
        final toy = await repository.getToyById(event.id);
        if (emit.isDone) return;
        emit(ToyDetailLoaded(toy));
      } catch (error) {
        if (emit.isDone) return;
        emit(ToyDetailError('$error'));
      }
    });
  }
}
