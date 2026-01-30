import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';

/// Phone login screen for entering phone number and requesting OTP.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  String _countryCode = '+91'; // Default to India
  String? _pendingPhoneNumber;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Listen to auth service changes for navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      authService.addListener(_onAuthServiceChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener
    final authService = context.read<AuthService>();
    authService.removeListener(_onAuthServiceChanged);
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAuthServiceChanged() {
    final authService = context.read<AuthService>();

    // Navigate to OTP screen when verificationId is set
    if (authService.verificationId != null &&
        _pendingPhoneNumber != null &&
        !_hasNavigated &&
        authService.error == null) {
      _hasNavigated = true;
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => OTPScreen(phoneNumber: _pendingPhoneNumber!),
            ),
          )
          .then((_) {
            // Reset navigation flag when returning
            _hasNavigated = false;
            _pendingPhoneNumber = null;
          });
    }
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = '$_countryCode${_phoneController.text.trim()}';
    final authService = context.read<AuthService>();

    // Store phone number for navigation
    _pendingPhoneNumber = phoneNumber;
    _hasNavigated = false;

    await authService.verifyPhoneNumber(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Text(
                      'Enter your\nphone number',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We will send you a verification code',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 48),

                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Country Code Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _countryCode,
                                items: const [
                                  DropdownMenuItem(
                                    value: '+91',
                                    child: Text('🇮🇳 +91'),
                                  ),
                                  DropdownMenuItem(
                                    value: '+1',
                                    child: Text('🇺🇸 +1'),
                                  ),
                                  DropdownMenuItem(
                                    value: '+44',
                                    child: Text('🇬🇧 +44'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _countryCode = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey[300],
                          ),

                          // Phone Number Field
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Phone number',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error Message
                    if (authService.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authService.error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authService.isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: authService.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Terms
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
