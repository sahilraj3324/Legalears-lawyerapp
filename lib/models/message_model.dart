/// Sync status for offline-first messages.
enum SyncStatus { pending, sent, failed }

/// Message type enum.
enum MessageType { text, image, document }

/// Sender type enum.
enum SenderType { lawyer, client }

/// Local message model for offline-first chat.
class MessageModel {
  final String id;
  final String localId; // UUID for offline tracking
  final String conversationId;
  final String senderId;
  final SenderType senderType;
  final String? content;
  final MessageType messageType;
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final String? fileMimeType;
  final int? fileSize;
  final bool isRead;
  final DateTime? readAt;
  final SyncStatus syncStatus;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.localId,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    this.content,
    this.messageType = MessageType.text,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    this.fileMimeType,
    this.fileSize,
    this.isRead = false,
    this.readAt,
    this.syncStatus = SyncStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      localId: json['localId'] ?? json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] == 'client'
          ? SenderType.client
          : SenderType.lawyer,
      content: json['content'],
      messageType: _parseMessageType(json['messageType']),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileMimeType: json['fileMimeType'],
      fileSize: json['fileSize'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      syncStatus: SyncStatus.sent,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'localId': localId,
    'conversationId': conversationId,
    'senderId': senderId,
    'senderType': senderType == SenderType.client ? 'client' : 'lawyer',
    'content': content,
    'messageType': messageType.name,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileMimeType': fileMimeType,
    'fileSize': fileSize,
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Convert to a map suitable for SQLite insertion.
  Map<String, dynamic> toMap() => {
    'id': id,
    'localId': localId,
    'conversationId': conversationId,
    'senderId': senderId,
    'senderType': senderType == SenderType.client ? 'client' : 'lawyer',
    'content': content,
    'messageType': messageType.name,
    'fileUrl': fileUrl,
    'localFilePath': localFilePath,
    'fileName': fileName,
    'fileMimeType': fileMimeType,
    'fileSize': fileSize,
    'isRead': isRead ? 1 : 0,
    'readAt': readAt?.toIso8601String(),
    'syncStatus': syncStatus.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      localId: map['localId'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderType: map['senderType'] == 'client'
          ? SenderType.client
          : SenderType.lawyer,
      content: map['content'],
      messageType: _parseMessageType(map['messageType']),
      fileUrl: map['fileUrl'],
      localFilePath: map['localFilePath'],
      fileName: map['fileName'],
      fileMimeType: map['fileMimeType'],
      fileSize: map['fileSize'],
      isRead: map['isRead'] == 1,
      readAt: map['readAt'] != null ? DateTime.tryParse(map['readAt']) : null,
      syncStatus: _parseSyncStatus(map['syncStatus']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MessageModel copyWith({
    String? id,
    SyncStatus? syncStatus,
    bool? isRead,
    DateTime? readAt,
    String? fileUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      localId: localId,
      conversationId: conversationId,
      senderId: senderId,
      senderType: senderType,
      content: content,
      messageType: messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      localFilePath: localFilePath,
      fileName: fileName,
      fileMimeType: fileMimeType,
      fileSize: fileSize,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
    );
  }

  bool get isPending => syncStatus == SyncStatus.pending;
  bool get isFailed => syncStatus == SyncStatus.failed;
  bool get isSent => syncStatus == SyncStatus.sent;
  bool get isFileMessage =>
      messageType == MessageType.image || messageType == MessageType.document;

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'document':
        return MessageType.document;
      default:
        return MessageType.text;
    }
  }

  static SyncStatus _parseSyncStatus(String? status) {
    switch (status) {
      case 'sent':
        return SyncStatus.sent;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }
}
