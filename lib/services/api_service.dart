import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/lawyer_model.dart';

/// Service for communicating with the backend API.
class ApiService {
  // TODO: Update this to your actual backend URL
  static const String baseUrl = 'https://legal-ears-backend.vercel.app';

  /// Login with Firebase token to get backend JWT.
  Future<AuthResponse> loginWithFirebase(
    String firebaseToken, {
    String? name,
  }) async {
    final url = Uri.parse('$baseUrl/lawyer/firebase-login');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $firebaseToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({if (name != null && name.isNotEmpty) 'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final errorBody = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] ?? 'Login failed',
      );
    }
  }

  /// Update lawyer profile by ID.
  ///
  /// Sends PATCH request to /lawyer/:id with the profile data.
  Future<Lawyer> updateLawyerProfile(
    String lawyerId,
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/lawyer/$lawyerId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Lawyer.fromJson(responseData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] ?? 'Failed to update profile',
      );
    }
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}
