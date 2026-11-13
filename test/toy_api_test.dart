import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playnest_toys/data/toy_api.dart';

void main() {
  test('API repository sends category=toys over HTTPS and parses response', () async {
    final dio = Dio(BaseOptions(baseUrl: ToyApiImpl.endpoint));
    var requests = 0;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests++;
      expect(options.uri.scheme, 'https');
      expect(options.path, '/api/products');
      expect(options.queryParameters['category'], 'toys');
      expect(options.queryParameters['seed'], 42026);
      handler.resolve(Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': [
            {'name': 'Cloud Teddy Bear', 'price': 15.5,
              'rating': 4.9, 'sku': 'TOY-12345-AB', 'inStock': true},
            {'name': 'Galaxy Building Blocks', 'price': 35.0,
              'rating': 4.2, 'sku': 'TOY-98765-ZX', 'inStock': false},
          ],
        },
      ));
    }));
    final api = ToyApiImpl(dio: dio);
    final all = await api.getToys();
    expect(all, hasLength(2));
    expect(all.first.id, 1);
    expect(all.last.category, 'Конструкторы');
    final second = await api.getToyById(2);
    expect(second.name, 'Galaxy Building Blocks');
    expect(requests, 2); // details perform another async HTTP request
  });

  test('ID outside catalog is rejected before contacting server', () async {
    final api = ToyApiImpl();
    await expectLater(api.getToyById(0), throwsA(isA<ToyApiException>()));
    await expectLater(api.getToyById(999), throwsA(isA<ToyApiException>()));
  });

  test('malformed JSON produces a readable API exception', () async {
    final dio = Dio(BaseOptions(baseUrl: ToyApiImpl.endpoint));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response<dynamic>(requestOptions: options,
        statusCode: 200, data: {'no-data': []}));
    }));
    final api = ToyApiImpl(dio: dio);
    await expectLater(api.getToys(), throwsA(isA<ToyApiException>()));
  });
}
