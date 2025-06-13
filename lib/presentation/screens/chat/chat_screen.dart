import 'package:flutter/material.dart';
import 'package:lostmate/presentation/screens/chat/chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data contoh untuk daftar chat
    final List<ChatPreview> chats = [
      ChatPreview(
        id: '1',
        name: 'Bella',
        lastMessage: 'Apakah barang saya sudah ditemukan?',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        avatarUrl: null,
      ),
      ChatPreview(
        id: '2',
        name: 'Kenzie',
        lastMessage: 'Terima kasih sudah menemukan barang saya',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
        avatarUrl: null,
      ),
      ChatPreview(
        id: '3',
        name: 'Telurmatakucing',
        lastMessage: 'Saya akan mengambilnya besok',
        time: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        avatarUrl: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatListItem(chat: chat);
        },
      ),
    );
  }
}

class ChatPreview {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final String? avatarUrl;

  ChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.avatarUrl,
  });
}

class ChatListItem extends StatelessWidget {
  final ChatPreview chat;

  const ChatListItem({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigasi ke halaman detail chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chatId: chat.id, name: chat.name),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        backgroundImage: chat.avatarUrl != null ? NetworkImage(chat.avatarUrl!) : null,
        child: chat.avatarUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
      ),
      title: Text(
        chat.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.unreadCount > 0 ? Colors.black : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(chat.time),
            style: TextStyle(
              fontSize: 12,
              color: chat.unreadCount > 0 ? const Color(0xFFFFC554) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFFFC554),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}
