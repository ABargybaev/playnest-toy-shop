/// One toy delivered by randomapi.dev (category=toys).
/// The provider does not supply numeric IDs; the fixed seed gives stable
/// ordering, so the app uses 1-based IDs for its search/detail flow.
class Toy {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String currency;
  final String sku;
  final double rating;
  final bool inStock;
  final String imageUrl;

  const Toy({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.category = 'Другие',
    this.currency = 'USD',
    this.sku = '',
    this.rating = 0,
    this.inStock = true,
    this.imageUrl = '',
  });

  factory Toy.fromApi(Map<String, dynamic> json, {required int id}) {
    final name = (json['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const FormatException('Toy has no name');
    }
    final price = (json['price'] as num?)?.toDouble();
    if (price == null || price < 0) {
      throw const FormatException('Invalid toy price');
    }
    return Toy(
      id: id,
      name: name,
      description: json['description'] as String? ?? '',
      category: categoryFor(name),
      price: price,
      currency: json['currency'] as String? ?? 'USD',
      sku: json['sku'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      inStock: json['inStock'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// The toy API exposes one broad category. Subcategories are derived from
  /// the item's actual title, not fabricated fields from the server.
  static String categoryFor(String title) {
    final value = title.toLowerCase();
    if (_hasAny(value, ['plush', 'teddy', 'stuffed', 'cuddly', 'soft toy'])) {
      return 'Мягкие';
    }
    if (_hasAny(value, ['puzzle', 'brain', 'board game', 'game set'])) {
      return 'Головоломки';
    }
    if (_hasAny(value, ['block', 'building', 'construction', 'brick', 'lego'])) {
      return 'Конструкторы';
    }
    if (_hasAny(value, ['car', 'truck', 'train', 'vehicle', 'racing', 'rocket', 'plane'])) {
      return 'Транспорт';
    }
    if (_hasAny(value, ['doll', 'figure', 'puppet', 'action figure'])) {
      return 'Фигурки';
    }
    if (_hasAny(value, ['robot', 'science', 'experiment', 'learning', 'stem'])) {
      return 'Развивающие';
    }
    return 'Другие';
  }

  static bool _hasAny(String text, List<String> words) =>
      words.any((word) => text.contains(word));
}
