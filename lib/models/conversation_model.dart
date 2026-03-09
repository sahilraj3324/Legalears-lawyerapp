/// Local conversation model for offline-first chat.
class ConversationModel {
  final String id;
  final String lawyerId;
  final String clientId;
  final String? clientName;
  final String? clientPhone;
  final String? clientProfilePic;
  final String? lawyerName;
  final String? lawyerPhone;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.lawyerId,
    required this.clientId,
    this.clientName,
    this.clientPhone,
    this.clientProfilePic,
    this.lawyerName,
    this.lawyerPhone,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
    this.isActive = true,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>?;
    final lawyer = json['lawyer'] as Map<String, dynamic>?;

    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      lawyerId: json['lawyerId'] is Map
          ? json['lawyerId']['_id'] ?? ''
          : json['lawyerId'] ?? '',
      clientId: json['clientId'] is Map
          ? json['clientId']['_id'] ?? ''
          : json['clientId'] ?? '',
      clientName: client?['name'],
      clientPhone: client?['phone'],
      clientProfilePic: client?['profilePic'],
      lawyerName: lawyer?['fullName'],
      lawyerPhone: lawyer?['phone'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: client?['isOnline'] ?? false,
      lastSeen: client?['lastSeen'] != null
          ? DateTime.tryParse(client!['lastSeen'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lawyerId': lawyerId,
    'clientId': clientId,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'clientProfilePic': clientProfilePic,
    'lawyerName': lawyerName,
    'lawyerPhone': lawyerPhone,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'unreadCount': unreadCount,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.toIso8601String(),
    'isActive': isActive,
  };

  /// Convert to a map suitable for SQLite insertion.
  Map<String, dynamic> toMap() => {
    'id': id,
    'lawyerId': lawyerId,
    'clientId': clientId,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'clientProfilePic': clientProfilePic,
    'lawyerName': lawyerName,
    'lawyerPhone': lawyerPhone,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'unreadCount': unreadCount,
    'isOnline': isOnline ? 1 : 0,
    'lastSeen': lastSeen?.toIso8601String(),
    'isActive': isActive ? 1 : 0,
  };

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'],
      lawyerId: map['lawyerId'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      clientPhone: map['clientPhone'],
      clientProfilePic: map['clientProfilePic'],
      lawyerName: map['lawyerName'],
      lawyerPhone: map['lawyerPhone'],
      lastMessage: map['lastMessage'],
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'])
          : null,
      unreadCount: map['unreadCount'] ?? 0,
      isOnline: map['isOnline'] == 1,
      lastSeen: map['lastSeen'] != null
          ? DateTime.tryParse(map['lastSeen'])
          : null,
      isActive: map['isActive'] == 1,
    );
  }

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ConversationModel(
      id: id,
      lawyerId: lawyerId,
      clientId: clientId,
      clientName: clientName,
      clientPhone: clientPhone,
      clientProfilePic: clientProfilePic,
      lawyerName: lawyerName,
      lawyerPhone: lawyerPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive,
    );
  }
}
