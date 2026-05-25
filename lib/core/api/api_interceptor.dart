import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor{
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // You can add headers or log the request here
    return handler.next(options);
  }
}