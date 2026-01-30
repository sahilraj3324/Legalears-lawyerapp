/// Lawyer model representing the authenticated lawyer from the backend.
class Lawyer {
  final String id;
  final String? name;
  final String phoneNumber;
  final String? email;
  final String? userType;
  final String? gender;
  final String? specialization;
  final DateTime? createdAt;

  Lawyer({
    required this.id,
    this.name,
    required this.phoneNumber,
    this.email,
    this.userType,
    this.gender,
    this.specialization,
    this.createdAt,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      email: json['email'],
      userType: json['userType'],
      gender: json['gender'],
      specialization: json['specialization'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType,
      'gender': gender,
      'specialization': specialization,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
