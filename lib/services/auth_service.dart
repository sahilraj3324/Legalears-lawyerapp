import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lawyer_model.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';

/// Authentication service handling Firebase phone auth and backend JWT.
///
/// Uses ChangeNotifier for state management with Provider.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final SecureStorageService _storageService;
  final ApiService _apiService;

  // State
  bool _isLoading = false;
  String? _error;
  Lawyer? _lawyer;
  bool _isAuthenticated = false;

  // OTP Verification state
  String? _verificationId;
  int? _resendToken;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Lawyer? get lawyer => _lawyer;
  bool get isAuthenticated => _isAuthenticated;
  String? get verificationId => _verificationId;

  AuthService({
    FirebaseAuth? firebaseAuth,
    SecureStorageService? storageService,
    ApiService? apiService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _storageService = storageService ?? SecureStorageService(),
       _apiService = apiService ?? ApiService();

  /// Check if user has a valid stored token on app start.
  Future<bool> checkAuthStatus() async {
    try {
      _setLoading(true);
      _clearError();

      final hasToken = await _storageService.hasToken();
      if (hasToken) {
        // Try to load cached lawyer data
        final lawyerJson = await _storageService.getLawyerData();
        if (lawyerJson != null) {
          _lawyer = Lawyer.fromJson(jsonDecode(lawyerJson));
        }
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      _setError('Failed to check auth status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Initiate phone number verification with Firebase.
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onAutoRetrievalTimeout,
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      _setError('Failed to verify phone number: $e');
      _setLoading(false);
    }
  }

  /// Called when verification is completed automatically (Android auto-retrieval).
  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    debugPrint('Auto verification completed');
    await _signInWithCredential(credential);
  }

  /// Called when verification fails.
  void _onVerificationFailed(FirebaseAuthException e) {
    debugPrint('Verification failed: ${e.message}');
    _setError(_getFirebaseErrorMessage(e.code));
    _setLoading(false);
  }

  /// Called when code is sent to the phone.
  void _onCodeSent(String verificationId, int? resendToken) {
    debugPrint('Code sent to phone');
    _verificationId = verificationId;
    _resendToken = resendToken;
    _setLoading(false);
    notifyListeners();
  }

  /// Called when auto-retrieval timeout expires.
  void _onAutoRetrievalTimeout(String verificationId) {
    debugPrint('Auto retrieval timeout');
    _verificationId = verificationId;
  }

  /// Verify the OTP entered by the user.
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _setError('Verification ID not found. Please request OTP again.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      _setError('Invalid OTP. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Sign in to Firebase with the phone credential.
  Future<bool> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        _setError('Failed to sign in with Firebase');
        _setLoading(false);
        return false;
      }

      debugPrint('Firebase sign in successful: ${user.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      _setLoading(false);
      return false;
    }
  }

  /// Exchange Firebase token with backend to get app JWT.
  Future<bool> authenticateWithBackend({String? name}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _setError('No Firebase user found');
        _setLoading(false);
        return false;
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        _setError('Failed to get Firebase ID token');
        _setLoading(false);
        return false;
      }

      debugPrint('Firebase ID token obtained, calling backend...');

      // Call backend API
      final authResponse = await _apiService.loginWithFirebase(
        idToken,
        name: name,
      );

      // Store token and lawyer data
      await _storageService.saveToken(authResponse.accessToken);
      await _storageService.saveLawyerData(
        jsonEncode(authResponse.lawyer.toJson()),
      );

      _lawyer = authResponse.lawyer;
      _isAuthenticated = true;

      debugPrint('Backend authentication successful');
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to authenticate with backend: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out from Firebase and clear stored tokens.
  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _firebaseAuth.signOut();
      await _storageService.clearAll();

      _lawyer = null;
      _isAuthenticated = false;
      _verificationId = null;
      _resendToken = null;

      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Resend OTP to the same phone number.
  Future<void> resendOTP(String phoneNumber) async {
    await verifyPhoneNumber(phoneNumber);
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Get user-friendly error message from Firebase error codes.
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'Session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
