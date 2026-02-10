import 'package:flutter/material.dart';

/// Dummy chat screen with placeholder conversations.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _dummyChats.length,
        itemBuilder: (context, index) {
          final chat = _dummyChats[index];
          return _ChatTile(
            name: chat['name']!,
            message: chat['message']!,
            time: chat['time']!,
            unread: chat['unread'] == 'true',
            avatarColor: _avatarColors[index % _avatarColors.length],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ChatDetailScreen(name: chat['name']!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}

final List<Color> _avatarColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.red,
  Colors.indigo,
];

final List<Map<String, String>> _dummyChats = [
  {
    'name': 'Rajesh Kumar',
    'message': 'Thank you for the consultation!',
    'time': '2:30 PM',
    'unread': 'true',
  },
  {
    'name': 'Priya Sharma',
    'message': 'Can we reschedule the meeting?',
    'time': '1:15 PM',
    'unread': 'true',
  },
  {
    'name': 'Amit Patel',
    'message': 'I have shared the documents.',
    'time': '12:00 PM',
    'unread': 'false',
  },
  {
    'name': 'Sunita Verma',
    'message': 'Please review the case details.',
    'time': '11:30 AM',
    'unread': 'false',
  },
  {
    'name': 'Vikram Singh',
    'message': 'The hearing is tomorrow at 10 AM.',
    'time': 'Yesterday',
    'unread': 'false',
  },
  {
    'name': 'Neha Gupta',
    'message': 'Thanks for the quick response!',
    'time': 'Yesterday',
    'unread': 'false',
  },
  {
    'name': 'Arun Joshi',
    'message': 'I need help with the property dispute.',
    'time': 'Mon',
    'unread': 'false',
  },
];

class _ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final Color avatarColor;
  final VoidCallback onTap;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: unread ? Colors.blue.withAlpha(8) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor.withAlpha(30),
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unread
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: Colors.grey[900],
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread ? Colors.blue[900] : Colors.grey[500],
                          fontWeight: unread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unread ? Colors.grey[800] : Colors.grey[500],
                            fontWeight: unread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dummy chat detail / conversation screen.
class _ChatDetailScreen extends StatelessWidget {
  final String name;

  const _ChatDetailScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withAlpha(40),
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green[200]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildReceivedMessage(
                    'Hello! I need legal advice regarding a property case.',
                    '10:00 AM',
                  ),
                  _buildSentMessage(
                    'Sure, I would be happy to help. Could you share the details?',
                    '10:02 AM',
                  ),
                  _buildReceivedMessage(
                    'I have a land dispute with my neighbor. He is claiming ownership.',
                    '10:05 AM',
                  ),
                  _buildSentMessage(
                    'Do you have the original property documents?',
                    '10:07 AM',
                  ),
                  _buildReceivedMessage(
                    'Yes, I have all the documents. Let me share them.',
                    '10:10 AM',
                  ),
                  _buildSentMessage(
                    'Please share the documents and I will review them.',
                    '10:12 AM',
                  ),
                ],
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 60),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 60),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(color: Colors.grey[900], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
