import 'package:dio/dio.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://gasapp.atwebpages.com/api/v1'));
  
  // Test how Dio resolves the URI
  final uri1 = dio.options.baseUrl;
  print('Base URL: $uri1');
  
  // simulate dio.post('/vendor/products')
  // Dio uses Uri.resolve or similar internally. We can check by just instantiating RequestOptions
  final options = RequestOptions(path: '/vendor/products', baseUrl: dio.options.baseUrl);
  print('Resolved URL 1: ${options.uri}');

  final options2 = RequestOptions(path: 'vendor/products', baseUrl: dio.options.baseUrl);
  print('Resolved URL 2: ${options2.uri}');
}
