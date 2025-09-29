import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  String get baseUrl => Env.get('API_BASE_URL');
  String get apiKey => Env.get('API_KEY');

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// POST Multipart (untuk upload file)
  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    File? file,
    String? fileFieldName,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    // Add headers (tanpa Content-Type karena multipart akan set otomatis)
    if (apiKey.isNotEmpty) {
      request.headers['X-API-KEY'] = apiKey;
    }

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add file jika ada
    if (file != null && fileFieldName != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
        ),
      );
    }

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  /// Header standar
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'X-API-KEY': apiKey,
    };
  }

  /// Handle response (otomatis decode JSON dan error handling)
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(
        'API Error: ${response.statusCode} - ${body['message'] ?? response.body}',
      );
    }
  }
}