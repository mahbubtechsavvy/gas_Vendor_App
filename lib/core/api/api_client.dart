import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../storage/storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _buildHeaders({
    String? idempotencyKey,
    String? branchId,
  }) async {
    final token = _storage.getAuthToken();
    final locale = _storage.getLocale();
    final activeBranchId = branchId ?? _storage.getSelectedBranchId();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': locale,
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (activeBranchId != null && activeBranchId.isNotEmpty) {
      headers['X-Branch-Id'] = activeBranchId;
    }

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['X-Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }

  Future<dynamic> get(String url, {Map<String, String>? queryParams, String? branchId}) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _buildHeaders(branchId: branchId);
      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Connection failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> post(
    String url, {
    dynamic body,
    String? idempotencyKey,
    String? branchId,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(
        idempotencyKey: idempotencyKey,
        branchId: branchId,
      );
      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Connection failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> put(
    String url, {
    dynamic body,
    String? idempotencyKey,
    String? branchId,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(
        idempotencyKey: idempotencyKey,
        branchId: branchId,
      );
      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Connection failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> patch(
    String url, {
    dynamic body,
    String? idempotencyKey,
    String? branchId,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(
        idempotencyKey: idempotencyKey,
        branchId: branchId,
      );
      final response = await _client.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Connection failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> delete(String url, {String? branchId}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(branchId: branchId);
      final response = await _client.delete(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Connection failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;
    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Failed to decode JSON: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    String errorMessage = 'An unexpected error occurred';
    String? errorCode;
    dynamic details;

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['error'] is Map<String, dynamic>) {
        final errMap = decodedBody['error'] as Map<String, dynamic>;
        if (errMap['message'] is String && (errMap['message'] as String).isNotEmpty) {
          errorMessage = errMap['message'] as String;
        } else if (errMap['message'] is List) {
          errorMessage = (errMap['message'] as List).join(', ');
        }
        errorCode = errMap['code']?.toString();
      } else if (decodedBody['message'] is List) {
        errorMessage = (decodedBody['message'] as List).join(', ');
      } else if (decodedBody['message'] is String) {
        errorMessage = decodedBody['message'];
      } else if (decodedBody['error'] is String) {
        errorMessage = decodedBody['error'];
      }
      errorCode ??= (decodedBody['code']?.toString() ?? decodedBody['statusCode']?.toString());
      details = decodedBody['details'] ?? decodedBody['errors'];
    } else if (decodedBody is String && decodedBody.isNotEmpty) {
      errorMessage = decodedBody;
    }

    if (response.statusCode == 401) {
      _storage.clearToken();
      if (errorMessage == 'An unexpected error occurred' || errorMessage.contains('bearer token') || errorMessage.contains('signature')) {
        errorMessage = 'Please sign in to continue';
      }
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      code: errorCode,
      details: details,
    );
  }
}
