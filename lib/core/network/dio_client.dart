import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  DioClient() : dio = Dio(BaseOptions(
    baseUrl: '',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
}
