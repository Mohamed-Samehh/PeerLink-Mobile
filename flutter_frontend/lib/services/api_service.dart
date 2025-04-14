import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  Future<http.Response> get(String endpoint, String? token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return _handleResponse(response);
  }

  Future<http.Response> post(
    String endpoint,
    dynamic data,
    String? token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields,
    File? file,
    String? token,
  ) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..fields.addAll(fields);

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<http.Response> put(
    String endpoint,
    dynamic data,
    String? token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<http.Response> putMultipart(
    String endpoint,
    Map<String, String> fields,
    File? file,
    String? token,
  ) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl$endpoint'))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..fields.addAll(fields);

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<http.Response> delete(String endpoint, String? token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw HttpException('Error: ${response.statusCode} - ${response.body}');
  }
}
