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
    return Scaffold(
      appBar: CommonAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : friends.isEmpty
              ? Center(child: Text("You don't have any friends yet"))
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final displayName = friend['displayName'] ?? 'Unnamed Friend';
                    final email = friend['email'] ?? '';

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text(displayName),
                        subtitle: Text(email),
                      ),
                    );
                  },
                ),
    );
  }
}
