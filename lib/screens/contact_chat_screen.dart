import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/utilities/user_data.dart';

class ContactChatsScreen extends StatefulWidget {
  final String friendId;

  ContactChatsScreen({required this.friendId});

  @override
  _ContactChatsScreenState createState() => _ContactChatsScreenState();
}

class _ContactChatsScreenState extends State<ContactChatsScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    socket = IO.io(chatUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userIdGlobal},
    });

    socket.connect();

    socket.onConnect((_) {
      print('Socket connected: ${socket.id}');
    });

    socket.on('newMessage', (data) {
      print("Received socket message: $data");

      if (data['senderId'] == widget.friendId || data['receiverId'] == widget.friendId) {
        setState(() {
          _messages.add({
            'text': data['content'],
            'sender': data['senderId'] == userIdGlobal ? 'me' : 'friend',
          });
        });
      }
    });

    socket.onDisconnect((_) => print('Socket disconnected'));
    socket.onConnectError((err) => print('Connect error: $err'));
    socket.onError((err) => print('Socket error: $err'));
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final messageData = {
      'senderId': userIdGlobal,
      'receiverId': widget.friendId,
      'content': _controller.text.trim(),
    };

    print("The Friend ID is: ${widget.friendId}");

    socket.emit('sendMessage', messageData);

    setState(() {
      _messages.add({'text': _controller.text.trim(), 'sender': 'me'});
      _controller.clear();
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friendId}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message['sender'] == 'me';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(color: isMe ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16), // bottom increased
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: sendMessage,
                    child: Icon(Icons.send),
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
