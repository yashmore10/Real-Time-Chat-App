import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authencatedUser = supabase.auth.currentUser;

    if (authencatedUser == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder(
      stream: supabase
          .from('chat')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (ctx, chatSnapshot) {
        // Loading
        if (chatSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        // No messages
        if (!chatSnapshot.hasData ||
            chatSnapshot.data!.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        final loadedMessages = chatSnapshot.data!;

        return ListView.builder(
          reverse: true, // newest at bottom
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatmessage = loadedMessages[index];

            final nextChatMessage =
                index + 1 < loadedMessages.length
                ? loadedMessages[index + 1]
                : null;

            final currentMessageUserId =
                chatmessage['user_id'];
            final nextMessageUserId =
                nextChatMessage != null
                ? nextChatMessage['user_id']
                : null;

            final nextUserIsSame =
                nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatmessage['text'],
                isMe:
                    authencatedUser.id ==
                    currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: supabase.storage
                    .from('avatars')
                    .getPublicUrl(
                      chatmessage['user_avatar_path'],
                    ),

                username: chatmessage['username'],
                message: chatmessage['text'],
                isMe:
                    authencatedUser.id ==
                    currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
