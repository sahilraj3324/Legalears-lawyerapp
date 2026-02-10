import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';

/// Multi-step onboarding screen for new lawyers to fill in their profile.
class LawyerOnboardingScreen extends StatefulWidget {
  const LawyerOnboardingScreen({super.key});

  @override
  State<LawyerOnboardingScreen> createState() => _LawyerOnboardingScreenState();
}

class _LawyerOnboardingScreenState extends State<LawyerOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Basic Info
  final _fullNameController = TextEditingController();
  String? _selectedGender;
  final _cityController = TextEditingController();

  // Step 2: Professional Info
  final List<String> _selectedSpecializations = [];
  final _courtController = TextEditingController();
  final _experienceController = TextEditingController();

  // Step 3: Additional Info
  final List<String> _selectedLanguages = [];
  final _emailController = TextEditingController();

  final List<String> _availableSpecializations = [
    'Criminal Law',
    'Civil Law',
    'Family Law',
    'Corporate Law',
    'Tax Law',
    'Property Law',
    'Labour Law',
    'Constitutional Law',
    'Intellectual Property',
    'Cyber Law',
    'Banking Law',
    'Immigration Law',
    'Environmental Law',
    'Human Rights',
    'Consumer Protection',
  ];

  final List<String> _availableLanguages = [
    'English',
    'Hindi',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Urdu',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Odia',
  ];

  final List<String> _genderOptions = [
    'male',
    'female',
    'other',
    'prefer_not_to_say',
  ];
  final Map<String, String> _genderLabels = {
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'prefer_not_to_say': 'Prefer not to say',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _cityController.dispose();
    _courtController.dispose();
    _experienceController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_fullNameController.text.trim().isEmpty) {
        _showSnackBar('Please enter your full name');
        return;
      }
      if (_selectedGender == null) {
        _showSnackBar('Please select your gender');
        return;
      }
      if (_cityController.text.trim().isEmpty) {
        _showSnackBar('Please enter your city');
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedSpecializations.isEmpty) {
        _showSnackBar('Please select at least one specialization');
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitProfile() async {
    final authService = context.read<AuthService>();

    final profileData = <String, dynamic>{
      'fullName': _fullNameController.text.trim(),
      'gender': _selectedGender,
      'city': _cityController.text.trim(),
      'specializations': _selectedSpecializations,
    };

    if (_courtController.text.trim().isNotEmpty) {
      profileData['court'] = _courtController.text.trim();
    }
    if (_experienceController.text.trim().isNotEmpty) {
      profileData['yearsOfExperience'] =
          int.tryParse(_experienceController.text.trim()) ?? 0;
    }
    if (_selectedLanguages.isNotEmpty) {
      profileData['languages'] = _selectedLanguages;
    }
    if (_emailController.text.trim().isNotEmpty) {
      profileData['email'] = _emailController.text.trim();
    }

    final success = await authService.updateProfile(profileData);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      _showSnackBar(authService.error ?? 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Complete Your\nProfile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / _totalSteps,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[900]!,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [_buildStep1(), _buildStep2(), _buildStep3()],
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[900],
                                side: BorderSide(color: Colors.blue[900]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentStep > 0 ? 2 : 1,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authService.isLoading
                                ? null
                                : (_currentStep < _totalSteps - 1
                                      ? _nextStep
                                      : _submitProfile),
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
                                : Text(
                                    _currentStep < _totalSteps - 1
                                        ? 'Continue'
                                        : 'Complete Profile',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Step 1: Full Name, Gender, City
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('Basic Information'),
          const SizedBox(height: 24),

          // Full Name
          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _fullNameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),

          // Gender
          _buildLabel('Gender'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.wc_outlined, color: Colors.blue[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text(
                        'Select gender',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(_genderLabels[gender] ?? gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // City
          _buildLabel('City'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _cityController,
            hint: 'Enter your city',
            icon: Icons.location_city_outlined,
          ),
        ],
      ),
    );
  }

  /// Step 2: Specializations, Court, Years of Experience
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('Professional Details'),
          const SizedBox(height: 24),

          // Specializations
          _buildLabel('Specializations'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return FilterChip(
                label: Text(spec),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecializations.add(spec);
                    } else {
                      _selectedSpecializations.remove(spec);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[900],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[900] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Court
          _buildLabel('Court (Optional)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _courtController,
            hint: 'e.g., Supreme Court, High Court',
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 24),

          // Years of Experience
          _buildLabel('Years of Experience (Optional)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _experienceController,
            hint: 'e.g., 5',
            icon: Icons.work_outline,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  /// Step 3: Languages, Email
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('Additional Information'),
          const SizedBox(height: 24),

          // Languages
          _buildLabel('Languages Spoken'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableLanguages.map((lang) {
              final isSelected = _selectedLanguages.contains(lang);
              return FilterChip(
                label: Text(lang),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLanguages.add(lang);
                    } else {
                      _selectedLanguages.remove(lang);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[900],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[900] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Email
          _buildLabel('Email Address (Optional)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'lawyer@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[900]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can update your profile anytime from the settings.',
                    style: TextStyle(color: Colors.blue[900], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[900]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
