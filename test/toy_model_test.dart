import 'package:flutter_test/flutter_test.dart';
import 'package:playnest_toys/data/toy.dart';

void main() {
  test('parses actual toys response fields and stable ID', () {
    final toy = Toy.fromApi({
      'name': 'Rainbow Plush Teddy Bear',
      'price': 24.95,
      'description': 'A colorful friend',
      'sku': 'TOY-00122-PL',
      'rating': 4.8,
      'currency': 'USD',
      'inStock': true,
      'imageUrl': 'https://example.org/image.png',
    }, id: 7);
    expect(toy.id, 7);
    expect(toy.category, 'Мягкие');
    expect(toy.name, 'Rainbow Plush Teddy Bear');
    expect(toy.formattedPrice, '\$24.95');
    expect(toy.inStock, isTrue);
  });

  test('classifies toy titles by actual keywords', () {
    expect(Toy.categoryFor('Wooden Building Blocks'), 'Конструкторы');
    expect(Toy.categoryFor('Dinosaur Puzzle'), 'Головоломки');
    expect(Toy.categoryFor('Rocket Train Set'), 'Транспорт');
    expect(Toy.categoryFor('Robot Learning Set'), 'Развивающие');
    expect(Toy.categoryFor('Surprise Box'), 'Другие');
  });

  test('rejects malformed toy payload', () {
    expect(() => Toy.fromApi({'name': '', 'price': 5}, id: 1), throwsFormatException);
    expect(() => Toy.fromApi({'name': 'Toy', 'price': -3}, id: 1), throwsFormatException);
  });
}
