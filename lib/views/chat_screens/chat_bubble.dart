import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? profilePhoto;
  final DateTime timestamp;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    this.profilePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser && profilePhoto != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundImage:
                  profilePhoto != null ? NetworkImage(profilePhoto!) : null,
              radius: 16,
            ),
          ),
        Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? ThemeColors.primaryColor.withOpacity(0.8)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      isCurrentUser ? const Radius.circular(12) : Radius.zero,
                  bottomRight:
                      !isCurrentUser ? const Radius.circular(12) : Radius.zero,
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                DateFormat('hh:mm a').format(timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
