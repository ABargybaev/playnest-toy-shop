import 'package:dio/dio.dart';
import 'toy.dart';

abstract class ToyApi {
  Future<List<Toy>> getToys();
  Future<Toy> getToyById(int id);
}

/// Real HTTPS API: https://randomapi.dev/apis/products
/// GET /api/products?category=toys&count=36&seed=42026&currency=USD
/// The provider generates mock products; it does NOT support /toys/{id}.
/// Detail lookup refetches the same reproducible list over HTTP and picks ID.
class ToyApiImpl implements ToyApi {
  static const endpoint = 'https://randomapi.dev';
  static const int catalogSize = 36;
  static const Map<String, dynamic> _query = {
    'category': 'toys',
    'count': catalogSize,
    'seed': 42026,
    'currency': 'USD',
    'minPrice': 8,
    'maxPrice': 109,
  };

  final Dio _dio;

  ToyApiImpl({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: endpoint,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ));

  @override
  Future<List<Toy>> getToys() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/products', queryParameters: _query,
      );
      final raw = response.data?['data'];
      if (raw is! List) {
        throw const FormatException('API returned invalid toy list');
      }
      final toys = <Toy>[];
      for (var i = 0; i < raw.length; i++) {
        final item = raw[i];
        if (item is! Map) {
          throw const FormatException('Invalid toy entry');
        }
        toys.add(Toy.fromApi(Map<String, dynamic>.from(item), id: i + 1));
      }
      return List.unmodifiable(toys);
    } on DioException catch (error) {
      throw ToyApiException(_explain(error));
    } on FormatException catch (error) {
      throw ToyApiException('Некорректные данные сервера: ${error.message}');
    } on TypeError {
      throw const ToyApiException('Сервер вернул неожиданный формат данных.');
    }
  }

  @override
  Future<Toy> getToyById(int id) async {
    if (id < 1 || id > catalogSize) {
      throw const ToyApiException('Игрушка с таким ID не найдена.');
    }
    final toys = await getToys();
    if (id > toys.length) {
      throw const ToyApiException('Игрушка с таким ID не найдена.');
    }
    return toys[id - 1];
  }

  static String _explain(DioException error) {
    if (error.response?.statusCode == 429) {
      return 'Слишком много запросов. Попробуйте позже.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Сервер долго отвечает. Повторите попытку.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Нет соединения с сервером. Проверьте интернет.';
    }
    return 'Ошибка сервера (${error.response?.statusCode ?? 'network'}).';
  }
}

class ToyApiException implements Exception {
  final String message;
  const ToyApiException(this.message);
  @override
  String toString() => message;
}
