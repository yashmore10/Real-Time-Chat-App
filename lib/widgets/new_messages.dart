import 'package:chat_app/screens/auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<NewMessages> createState() {
    return _NewMessagesState();
  }
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) return;

    final user = supabase.auth.currentUser!;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      // Fetch profile
      final profile = await supabase
          .from('profiles')
          .select('username, avatar_path')
          .eq('id', user.id)
          .single();

      // Insert message
      await supabase.from('chat').insert({
        'text': enteredMessage,
        'user_id': user.id,
        'username': profile['username'],
        'user_avatar_path': profile['avatar_path'],
      });
    } catch (error) {
      _messageController.text = enteredMessage;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Message failed to send. Try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                textCapitalization:
                    TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  labelText: 'Send a message...',
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
