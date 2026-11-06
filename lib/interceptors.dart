import 'package:dio/dio.dart';

// Свой интерсептор: автоматически добавляет токен в заголовок каждого запроса
class InterceptorsApp extends Interceptor {
  final String token;

  InterceptorsApp(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Api-Key'] = token;
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.next(err);
  }
}
