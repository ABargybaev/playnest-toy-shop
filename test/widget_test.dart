import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playnest_toys/data/toy.dart';
import 'package:playnest_toys/data/toy_api.dart';
import 'package:playnest_toys/main.dart';
import 'package:playnest_toys/widgets/toy_card.dart';

const toy = Toy(
  id: 1,
  name: 'Soft Teddy Bear',
  description: 'A fluffy toy.',
  price: 25.5,
  rating: 4.8,
  category: 'Мягкие',
);

class FakeToyApi implements ToyApi {
  @override
  Future<List<Toy>> getToys() async => [toy];

  @override
  Future<Toy> getToyById(int id) async => toy;
}

/// The catalog uses a CustomScrollView with a tall header and a lazy sliver.
/// At the default widget-test screen size, ToyCard isn't built until the
/// user scrolls to it. scrollUntilVisible works even for not-yet-built items.
Future<void> showFirstToyCard(WidgetTester tester) async {
  final catalogScroll = find.descendant(
    of: find.byType(CustomScrollView),
    matching: find.byType(Scrollable),
  ).first;

  await tester.scrollUntilVisible(
    find.byType(ToyCard),
    220,
    scrollable: catalogScroll,
    maxScrolls: 20,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders new catalog and opens real detail screen', (tester) async {
    await tester.pumpWidget(PlayNestApp(toyApi: FakeToyApi()));
    await tester.pumpAndSettle();
    expect(find.text('playnest.'), findsOneWidget);

    await showFirstToyCard(tester);
    expect(find.byType(ToyCard), findsOneWidget);
    expect(find.text('Soft Teddy Bear'), findsOneWidget);

    await tester.tap(find.byType(ToyCard));
    await tester.pumpAndSettle();
    expect(find.text('Игрушка #1'), findsOneWidget);
    expect(find.text('Soft Teddy Bear'), findsOneWidget);
  });

  testWidgets('adds a toy then shows its cart quantity', (tester) async {
    await tester.pumpWidget(PlayNestApp(toyApi: FakeToyApi()));
    await tester.pumpAndSettle();

    await showFirstToyCard(tester);
    final addButton = find.descendant(
      of: find.byType(ToyCard),
      matching: find.byIcon(Icons.add_rounded),
    );
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Корзина'));
    await tester.pumpAndSettle();
    expect(find.text('Soft Teddy Bear'), findsOneWidget);
    expect(find.text('Всего игрушек: 1'), findsOneWidget);
  });
}
