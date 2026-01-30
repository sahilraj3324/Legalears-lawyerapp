import 'lawyer_model.dart';

/// Response model for the /lawyer/firebase-login endpoint.
class AuthResponse {
  final Lawyer lawyer;
  final String accessToken;

  AuthResponse({required this.lawyer, required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      lawyer: Lawyer.fromJson(json['lawyer'] ?? {}),
      accessToken: json['accessToken'] ?? '',
    );
  }
}
