import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// SQLite database manager for offline-first chat.
class ChatDatabase {
  static Database? _database;
  static const String _dbName = 'legal_ears_chat.db';
  static const int _dbVersion = 1;

  /// Get database instance (lazy singleton).
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);

    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        lawyerId TEXT NOT NULL,
        clientId TEXT NOT NULL,
        clientName TEXT,
        clientPhone TEXT,
        clientProfilePic TEXT,
        lawyerName TEXT,
        lawyerPhone TEXT,
        lastMessage TEXT,
        lastMessageAt TEXT,
        unreadCount INTEGER DEFAULT 0,
        isOnline INTEGER DEFAULT 0,
        lastSeen TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        localId TEXT PRIMARY KEY,
        id TEXT,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        senderType TEXT NOT NULL,
        content TEXT,
        messageType TEXT DEFAULT 'text',
        fileUrl TEXT,
        localFilePath TEXT,
        fileName TEXT,
        fileMimeType TEXT,
        fileSize INTEGER,
        isRead INTEGER DEFAULT 0,
        readAt TEXT,
        syncStatus TEXT DEFAULT 'pending',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES conversations(id)
      )
    ''');

    // Indexes for performance
    await db.execute(
      'CREATE INDEX idx_messages_conversation ON messages(conversationId, createdAt)',
    );
    await db.execute('CREATE INDEX idx_messages_sync ON messages(syncStatus)');
    await db.execute(
      'CREATE INDEX idx_conversations_last_msg ON conversations(lastMessageAt)',
    );
  }

  // ──────────────── Conversations ────────────────

  /// Insert or update a conversation.
  static Future<void> upsertConversation(ConversationModel conversation) async {
    final db = await database;
    await db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all conversations, most recent first.
  static Future<List<ConversationModel>> getConversations() async {
    final db = await database;
    final rows = await db.query(
      'conversations',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'lastMessageAt DESC',
    );
    return rows.map((r) => ConversationModel.fromMap(r)).toList();
  }

  /// Get a single conversation by ID.
  static Future<ConversationModel?> getConversation(String id) async {
    final db = await database;
    final rows = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ConversationModel.fromMap(rows.first);
  }

  /// Update conversation's last message and unread count.
  static Future<void> updateConversationPreview(
    String conversationId,
    String lastMessage,
    DateTime lastMessageAt, {
    int? unreadCount,
  }) async {
    final db = await database;
    final values = <String, dynamic>{
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
    if (unreadCount != null) {
      values['unreadCount'] = unreadCount;
    }
    await db.update(
      'conversations',
      values,
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Update online status for a conversation's participant.
  static Future<void> updateOnlineStatus(
    String conversationId,
    bool isOnline,
    DateTime? lastSeen,
  ) async {
    final db = await database;
    await db.update(
      'conversations',
      {
        'isOnline': isOnline ? 1 : 0,
        if (lastSeen != null) 'lastSeen': lastSeen.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Reset unread count for a conversation.
  static Future<void> resetUnreadCount(String conversationId) async {
    final db = await database;
    await db.update(
      'conversations',
      {'unreadCount': 0},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // ──────────────── Messages ────────────────

  /// Insert a message (or update if localId already exists).
  static Future<void> upsertMessage(MessageModel message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get messages for a conversation, newest first with pagination.
  static Future<List<MessageModel>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'createdAt ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => MessageModel.fromMap(r)).toList();
  }

  /// Get all pending (unsent) messages.
  static Future<List<MessageModel>> getPendingMessages() async {
    final db = await database;
    final rows = await db.query(
      'messages',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
      orderBy: 'createdAt ASC',
    );
    return rows.map((r) => MessageModel.fromMap(r)).toList();
  }

  /// Update a message's sync status.
  static Future<void> updateMessageSyncStatus(
    String localId,
    SyncStatus status, {
    String? serverId,
  }) async {
    final db = await database;
    final values = <String, dynamic>{'syncStatus': status.name};
    if (serverId != null) {
      values['id'] = serverId;
    }
    await db.update(
      'messages',
      values,
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  /// Mark all messages in a conversation as read.
  static Future<void> markMessagesAsRead(
    String conversationId,
    String myId,
  ) async {
    final db = await database;
    await db.update(
      'messages',
      {'isRead': 1, 'readAt': DateTime.now().toIso8601String()},
      where: 'conversationId = ? AND senderId != ? AND isRead = 0',
      whereArgs: [conversationId, myId],
    );
  }

  /// Check if a message with the given server ID already exists.
  static Future<bool> messageExists(String serverId) async {
    final db = await database;
    final rows = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [serverId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Count total messages in the database (for debugging).
  static Future<int> getMessageCount(String conversationId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE conversationId = ?',
      [conversationId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all data (for logout).
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('conversations');
  }
}
