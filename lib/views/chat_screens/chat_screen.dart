import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/views/chat_screens/chat_bubble.dart';
import 'package:zoomio_driverzoomio/views/chat_screens/chat_services.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_messaging_textfield.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class DriverChatScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String bookingId;
  final String userName;
  final String? userProfilePhoto;

  const DriverChatScreen({
    Key? key,
    required this.userId,
    required this.userEmail,
    required this.bookingId,
    required this.userName,
    this.userProfilePhoto,
  }) : super(key: key);

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _chatServices.sendMessage(
          widget.userId,
          _messageController.text.trim(),
        );
        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending message: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _buildProfileAvatar(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName),
          ],
        ),
        backgroundColor: ThemeColors.primaryColor,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (widget.userProfilePhoto == null || widget.userProfilePhoto!.isEmpty) {
      return const Icon(Icons.person);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundImage: NetworkImage(widget.userProfilePhoto!),
        backgroundColor: Colors.grey.shade300,
        child:
            widget.userProfilePhoto == null ? const Icon(Icons.person) : null,
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatServices.getMessages(
        widget.userId,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use WidgetsBinding to ensure scroll happens after the frame is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ChatBubble(
        message: data['message'],
        isCurrentUser: isCurrentUser,
        profilePhoto: isCurrentUser ? null : widget.userProfilePhoto,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: MessagingTextField(
              controller: _messageController,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              color: ThemeColors.primaryColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
