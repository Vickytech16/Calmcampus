import 'dart:convert';
import 'package:calmcampus/Contents/Drawer.dart';
import 'package:calmcampus/screens/contact_chat_screen.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calmcampus/utilities/user_data.dart'; // contains `jwt_token`

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final url = Uri.parse('${baseUrl}friend-requests/friends');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt_token'},
    );

    print("Friends response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        friends = data.map((item) => {
          'friend_id': item['friendId'],
          'name': item['displayName'] ?? 'Friend' // fallback name
        }).toList();
        isLoading = false;
      });
    } else {
      print('Failed to load friends - Status: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/Misc/background.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          drawer: CustomDrawer(),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: const [
              Icon(Icons.notifications, color: Colors.black),
              SizedBox(width: 16),
            ],
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/brain_icon.png'),
                ),
                SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'Karma'),
                    children: [
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'alm '),
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'ampus'),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : friends.isEmpty
                    ? Center(child: Text('No friends found'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chat with Friends',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                final friend = friends[index];
                                final friendId = friend['friend_id'];
                                final friendName = friend['name'];

                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(Icons.person, color: Colors.grey[700]),
                                    ),
                                    title: Text('Name: $friendName'),
                                    subtitle: const Text('Tap to chat'),
                                    trailing: const Icon(Icons.chat, color: Colors.grey),
                                    onTap: () {
                                      print(friendId);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>

                                              ContactChatsScreen(friendId: friendId),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
