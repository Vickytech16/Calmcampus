import 'package:calmcampus/Contents/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/Contents/appbar.dart';
import 'package:calmcampus/utilities/user_data.dart';

class FriendsListScreen extends StatefulWidget {
  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final url = Uri.parse('${baseUrl}friend-requests/friends');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt_token',
          'Content-Type': 'application/json',
        },
      );

      print("Friends response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friends = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print('Failed to load friends - Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching friends: $e');
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
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            const SizedBox(width: 8),
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
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : friends.isEmpty
                ? const Center(
                    child: Text(
                      "You don't have any friends yet",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final displayName = friend['displayName'] ?? 'Unnamed Friend';
                      final email = friend['email'] ?? '';

                      return Card(
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.black),
                          title: Text(
                            displayName,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            email,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    ),
  ],
);
  }}