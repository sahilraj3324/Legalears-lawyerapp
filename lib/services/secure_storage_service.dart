import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for secure token storage using flutter_secure_storage.
class SecureStorageService {
  static const String _tokenKey = 'backend_jwt_token';
  static const String _lawyerDataKey = 'lawyer_data';

  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  /// Save the backend JWT token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the stored JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored JWT token (for logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if a token exists.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save lawyer data as JSON string.
  Future<void> saveLawyerData(String lawyerJson) async {
    await _storage.write(key: _lawyerDataKey, value: lawyerJson);
  }

  /// Retrieve stored lawyer data.
  Future<String?> getLawyerData() async {
    return await _storage.read(key: _lawyerDataKey);
  }

  /// Delete all stored data (full logout).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
