/// Lawyer model representing the authenticated lawyer from the backend.
class Lawyer {
  final String id;
  final String? fullName;
  final String phoneNumber;
  final String? email;
  final String? userType;
  final String? gender;
  final List<String> specializations;
  final String? city;
  final String? court;
  final int? yearsOfExperience;
  final List<String> languages;
  final bool isVerified;
  final String? firebaseUid;
  final DateTime? createdAt;

  Lawyer({
    required this.id,
    this.fullName,
    required this.phoneNumber,
    this.email,
    this.userType,
    this.gender,
    this.specializations = const [],
    this.city,
    this.court,
    this.yearsOfExperience,
    this.languages = const [],
    this.isVerified = false,
    this.firebaseUid,
    this.createdAt,
  });

  /// Check if the lawyer has completed their profile onboarding.
  bool get isProfileComplete {
    return fullName != null &&
        fullName!.isNotEmpty &&
        fullName != 'New Lawyer' &&
        gender != null &&
        gender!.isNotEmpty &&
        city != null &&
        city!.isNotEmpty &&
        specializations.isNotEmpty;
  }

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? json['name'],
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      email: json['email'],
      userType: json['userType'],
      gender: json['gender'],
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'])
          : [],
      city: json['city'],
      court: json['court'],
      yearsOfExperience: json['yearsOfExperience'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      isVerified: json['isVerified'] ?? false,
      firebaseUid: json['firebaseUid'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType,
      'gender': gender,
      'specializations': specializations,
      'city': city,
      'court': court,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'isVerified': isVerified,
      'firebaseUid': firebaseUid,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
