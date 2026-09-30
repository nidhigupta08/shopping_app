import 'package:dio/dio.dart';

class ProductApiService {
  final Dio dio = Dio();

  Future<List<dynamic>> fetchProducts() async {
    final response = await dio.get(
      'http://localhost:5000/api/products',
    );

    return response.data;
  }
}