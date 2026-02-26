import 'package:dio/dio.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??=
        Dio(
            BaseOptions(
              baseUrl: 'https://sowlab.com/assignment/',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          )
          ..interceptors.add(
            LogInterceptor(
              requestBody: true,
              responseBody: true,
              // ignore: avoid_print
              logPrint: (obj) => print(obj),
            ),
          );
    return _instance!;
  }
}
