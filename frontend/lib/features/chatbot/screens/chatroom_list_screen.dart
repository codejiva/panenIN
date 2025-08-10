// lib/features/chatbot/screens/enhanced_chatroom_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:PanenIn/features/chatbot/models/chatroom_item_model.dart';
import 'package:PanenIn/features/chatbot/services/chatbot_service.dart';

class ChatroomListScreen extends StatefulWidget {
  const ChatroomListScreen({super.key});

  @override
  _ChatroomListScreenState createState() => _ChatroomListScreenState();
}

class _ChatroomListScreenState extends State<ChatroomListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChatroomItem> _chatrooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversations = await ChatService.getUserConversations(context);

      setState(() {
        _chatrooms = conversations.map((conv) => conv.toChatroomItem()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load conversations: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  List<ChatroomItem> get _filteredChatrooms {
    if (_searchQuery.isEmpty) {
      return _chatrooms;
    }
    return _chatrooms
        .where((chatroom) =>
    chatroom.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        chatroom.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshConversations,
        color: const Color(0xFF48BB78),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.go('/chatbot'),
      ),
      title: const Text(
        'Chats',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: _refreshConversations,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF48BB78)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final filteredChatrooms = _filteredChatrooms;

    if (filteredChatrooms.isEmpty) {
      return _buildEmptyState();
    }

    return _buildChatroomList(filteredChatrooms);
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading chats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshConversations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48BB78),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF48BB78).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFF48BB78),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No chats found' : 'No chats yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Start a new conversation with Panen AI to get instant help with farming questions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _startNewAIChat(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48BB78),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.smart_toy, size: 20),
              label: const Text('Start Chat with AI'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatroomList(List<ChatroomItem> chatrooms) {
    return ListView.builder(
      itemCount: chatrooms.length,
      itemBuilder: (context, index) {
        final chatroom = chatrooms[index];
        return _buildChatroomItem(chatroom);
      },
    );
  }

  Widget _buildChatroomItem(ChatroomItem chatroom) {
    return Dismissible(
      key: Key(chatroom.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) => _confirmDeleteChatroom(chatroom),
      onDismissed: (direction) => _deleteChatroom(chatroom),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          onTap: () => _openChatroom(chatroom),
          leading: _buildAvatar(chatroom),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chatroom.title,
                  style: TextStyle(
                    fontWeight: chatroom.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chatroom.isOnline)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF48BB78),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              chatroom.lastMessage.isNotEmpty
                  ? chatroom.lastMessage
                  : 'No messages yet',
              style: TextStyle(
                color: chatroom.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: chatroom.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chatroom.timestamp,
                style: TextStyle(
                  color: chatroom.unreadCount > 0 ? const Color(0xFF48BB78) : Colors.grey[500],
                  fontSize: 12,
                  fontWeight: chatroom.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (chatroom.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF48BB78),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    chatroom.unreadCount > 99 ? '99+' : chatroom.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatroomItem chatroom) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: chatroom.avatarColor,
          child: chatroom.isAI
              ? const Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 24,
          )
              : Text(
            chatroom.title.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (chatroom.isOnline && chatroom.isAI)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF48BB78),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showNewChatOptions(context),
      backgroundColor: const Color(0xFF48BB78),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _openChatroom(ChatroomItem chatroom) {
    if (chatroom.isAI) {
      // Navigate to AI chat with conversation ID
      context.go('/chatbot/list/chat?conversationId=${chatroom.id}');
    } else {
      // Navigate to community chat (placeholder)
      _showComingSoonDialog();
    }
  }

  Future<bool?> _confirmDeleteChatroom(ChatroomItem chatroom) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${chatroom.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteChatroom(ChatroomItem chatroom) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await ChatService.deleteConversation(context, chatroom.id);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Remove from local list
      setState(() {
        _chatrooms.removeWhere((item) => item.id == chatroom.id);
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat deleted successfully'),
            backgroundColor: Color(0xFF48BB78),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startNewAIChat() {
    context.go('/chatbot/list/chat');
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start New Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF48BB78),
                child: Icon(Icons.smart_toy, color: Colors.white),
              ),
              title: const Text('Chat with Panen AI'),
              subtitle: const Text('Get instant help with farming questions'),
              onTap: () {
                Navigator.pop(context);
                _startNewAIChat();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF3182CE),
                child: Icon(Icons.group, color: Colors.white),
              ),
              title: const Text('Join Community Chat'),
              subtitle: const Text('Connect with fellow farmers'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived Chats'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Chat Settings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is currently under development and will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}