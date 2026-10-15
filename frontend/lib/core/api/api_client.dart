import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Standard response wrapper for CAMSO API calls.
class ApiResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final T? data;
  final dynamic rawJson;
  final String? errorMessage;

  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.rawJson,
    this.errorMessage,
  });

  factory ApiResponse.success(T data, {int statusCode = 200, dynamic rawJson}) {
    return ApiResponse(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      rawJson: rawJson,
    );
  }

  factory ApiResponse.failure(String message, {int statusCode = 500, dynamic rawJson}) {
    return ApiResponse(
      isSuccess: false,
      statusCode: statusCode,
      errorMessage: message,
      rawJson: rawJson,
    );
  }
}

/// Centralized HTTP client using package:http for cross-platform
/// CAMSO backend communication (Flutter Web, Android, iOS, Desktop).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api/v1',
  );

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  http.Client _client = http.Client();

  /// Injects a custom [http.Client] for testing.
  void setClientForTesting(http.Client client) {
    _client = client;
  }

  /// Resets client to default [http.Client].
  void resetClient() {
    _client = http.Client();
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Execute GET request
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.failure('Request timed out. Please check your connection.', statusCode: 408);
    } catch (e) {
      return ApiResponse.failure('Network connection error: $e', statusCode: 0);
    }
  }

  /// Execute POST request
  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.failure('Request timed out. Please check your connection.', statusCode: 408);
    } catch (e) {
      return ApiResponse.failure('Network connection error: $e', statusCode: 0);
    }
  }

  /// Execute PUT request
  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .put(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.failure('Request timed out. Please check your connection.', statusCode: 408);
    } catch (e) {
      return ApiResponse.failure('Network connection error: $e', statusCode: 0);
    }
  }

  /// Execute PATCH request
  Future<ApiResponse<dynamic>> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .patch(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.failure('Request timed out. Please check your connection.', statusCode: 408);
    } catch (e) {
      return ApiResponse.failure('Network connection error: $e', statusCode: 0);
    }
  }

  /// Execute DELETE request
  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.failure('Request timed out. Please check your connection.', statusCode: 408);
    } catch (e) {
      return ApiResponse.failure('Network connection error: $e', statusCode: 0);
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    dynamic parsed;
    if (responseBody.isNotEmpty) {
      try {
        parsed = jsonDecode(responseBody);
      } catch (_) {
        parsed = responseBody;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      final data = (parsed is Map && parsed.containsKey('data')) ? parsed['data'] : parsed;
      return ApiResponse.success(data, statusCode: statusCode, rawJson: parsed);
    } else {
      String errorMessage = 'Request failed with status $statusCode';
      if (parsed is Map) {
        final rawError = parsed['error'];
        if (rawError is Map && rawError['message'] != null && rawError['message'].toString().trim().isNotEmpty) {
          errorMessage = rawError['message'].toString();
        } else if (parsed['message'] != null && parsed['message'].toString().trim().isNotEmpty) {
          errorMessage = parsed['message'].toString();
        } else if (rawError is String && rawError.trim().isNotEmpty) {
          errorMessage = rawError.trim();
        } else if (rawError != null && rawError is! Map && rawError.toString().trim().isNotEmpty) {
          errorMessage = rawError.toString();
        }
      } else if (parsed is String && parsed.trim().isNotEmpty) {
        errorMessage = parsed.trim();
      }
      return ApiResponse.failure(errorMessage, statusCode: statusCode, rawJson: parsed);
    }
  }
}
