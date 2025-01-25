import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room ID - ensure it's always the same for both users
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Sort to ensure the same room ID regardless of sender/receiver
    String chatRoomId = ids.join('_');

    // Add message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Sort user IDs to ensure consistent chat room ID
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: false);
  }

  Stream<int> getUnreadMessageCount(String userId) {
    final currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((chatRooms) async {
      int totalUnread = 0;

      for (var room in chatRooms.docs) {
        final messages = await room.reference
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

        totalUnread += messages.docs.length;
      }

      return totalUnread;
    });
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    final chatRoomId = ids.join('_');

    final messages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

// Message model
class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}

class MessageBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;

  const MessageBadge({
    Key? key,
    required this.child,
    required this.count,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
