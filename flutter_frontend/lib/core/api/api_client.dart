import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import 'endpoints.dart';

class ApiClient {
  final http.Client _client = http.Client();
  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> get _headers {
    final headers = {'Accept': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        Endpoints.baseUrl + endpoint,
      ).replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers);
      return _processResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? fields,
    Map<String, File>? files,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final Uri uri = Uri.parse(Endpoints.baseUrl + endpoint);
      http.Response response;

      if (files != null && files.isNotEmpty) {
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(_headers);

        if (fields != null) {
          request.fields.addAll(fields);
        }

        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await _client.post(
          uri,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: data != null ? jsonEncode(data) : null,
        );
      }

      return _processResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? fields,
    Map<String, File>? files,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final Uri uri = Uri.parse(Endpoints.baseUrl + endpoint);
      http.Response response;

      if ((endpoint == Endpoints.profile) ||
          (files != null && files.isNotEmpty)) {
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(_headers);

        Map<String, String> updatedFields = fields ?? {};
        updatedFields['_method'] = 'PUT';

        request.fields.addAll(updatedFields);

        if (files != null && files.isNotEmpty) {
          for (final entry in files.entries) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await _client.put(
          uri,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: data != null ? jsonEncode(data) : null,
        );
      }

      return _processResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse(Endpoints.baseUrl + endpoint),
        headers: _headers,
      );

      return _processResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse<T>(success: true);
      }

      final jsonData = json.decode(response.body);
      if (fromJson != null) {
        final data = fromJson(jsonData is List ? {'data': jsonData} : jsonData);
        return ApiResponse<T>(success: true, data: data);
      }

      return ApiResponse<T>(success: true, data: jsonData as T);
    } else {
      Map<String, dynamic>? errorData;
      String? errorMessage;

      try {
        final jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          errorMessage = jsonData['message'];
          errorData = jsonData['errors'];
        }
      } catch (_) {
        errorMessage = 'Unknown error occurred';
      }

      return ApiResponse<T>(
        success: false,
        message:
            errorMessage ??
            'Request failed with status: ${response.statusCode}',
        errors: errorData,
      );
    }
  }
}
