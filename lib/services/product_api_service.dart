
import 'package:dio/dio.dart';

class ProductApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<dynamic>> fetchProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final response = await dio.get(
      '/products',
      queryParameters: {
        'category': ?category,
        'minPrice': ?minPrice,
        'maxPrice': ?maxPrice,
      },
    );

    return response.data as List<dynamic>;
  }
}
