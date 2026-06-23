import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        followRedirects: true,
        maxRedirects: 5,
        // Use plain text response to avoid auto-JSON parsing failures
        // when PHP outputs warnings/deprecation notices before JSON
        responseType: ResponseType.plain,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configure HTTP client to accept bad SSL certificates
    // (AwardSpace free hosting has an invalid/self-signed certificate)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Add interceptors for logging and auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to headers
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          debugPrint('REQUEST[${options.method}] => FULL URL: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Parse plain text response as JSON, stripping any PHP
          // warnings/deprecation notices that appear before the JSON
          if (response.data is String) {
            String rawData = response.data as String;
            // Find the first { or [ which marks the start of JSON
            final jsonStartBrace = rawData.indexOf('{');
            final jsonStartBracket = rawData.indexOf('[');
            int jsonStart = -1;
            if (jsonStartBrace >= 0 && jsonStartBracket >= 0) {
              jsonStart = jsonStartBrace < jsonStartBracket
                  ? jsonStartBrace
                  : jsonStartBracket;
            } else if (jsonStartBrace >= 0) {
              jsonStart = jsonStartBrace;
            } else if (jsonStartBracket >= 0) {
              jsonStart = jsonStartBracket;
            }

            if (jsonStart > 0) {
              debugPrint(
                'WARNING: Stripped $jsonStart chars of non-JSON prefix from response',
              );
              rawData = rawData.substring(jsonStart);
            }

            if (jsonStart >= 0) {
              try {
                response.data = jsonDecode(rawData);
              } catch (e) {
                debugPrint('JSON parse error: $e');
                debugPrint('Raw response: $rawData');
              }
            }
          }
          debugPrint(
            'RESPONSE[${response.statusCode}] => DATA: ${response.data}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            'ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
          );
          debugPrint('ERROR TYPE: ${error.type}');
          debugPrint('ERROR DETAILS: ${error.error}');
          debugPrint('REQUEST URL: ${error.requestOptions.uri}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload File
  Future<Response> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(endpoint, data: formData);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Dio Errors
  String _handleError(DioException error) {
    String errorMessage = 'Something went wrong';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      errorMessage =
          'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response?.data != null) {
        if (error.response!.data is Map) {
          errorMessage =
              error.response!.data['message'] ??
              error.response!.data['error'] ??
              errorMessage;
        } else {
          errorMessage = error.response!.data.toString();
          if (errorMessage.length > 200) {
            errorMessage = '${errorMessage.substring(0, 200)}...';
          }
        }
      } else {
        errorMessage = 'Server error: ${error.response?.statusCode}';
      }
    } else if (error.type == DioExceptionType.badCertificate) {
      errorMessage = 'SSL certificate error. Please try again.';
    } else if (error.type == DioExceptionType.cancel) {
      errorMessage = 'Request cancelled';
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage =
          'Could not connect to server. Please check your internet connection.';
    } else {
      errorMessage =
          error.message ??
          'An unexpected network error occurred. Please try again.';
    }

    return errorMessage;
  }
}
