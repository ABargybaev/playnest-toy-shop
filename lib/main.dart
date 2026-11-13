import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cart_bloc.dart';
import 'bloc/catalog_bloc.dart';
import 'bloc/favorites_bloc.dart';
import 'data/toy_api.dart';
import 'screens/store_shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlayNestApp());
}

 
class PlayNestApp extends StatelessWidget {
  final ToyApi? toyApi;
  const PlayNestApp({super.key, this.toyApi});

  @override
  Widget build(BuildContext context) => RepositoryProvider<ToyApi>(
    create: (_) => toyApi ?? ToyApiImpl(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider<CatalogBloc>(create: (context) =>
          CatalogBloc(context.read<ToyApi>())..add(const CatalogRequested())),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: MaterialApp(
        title: 'PlayNest Toys',
        debugShowCheckedModeBanner: false,
        theme: playNestTheme(),
        home: const StoreShell(),
      ),
    ),
  );
}
