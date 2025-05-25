import 'package:flutter/material.dart';
import 'package:calmcampus/Contents/appbar.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<Map<String, dynamic>> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
  }

  Future<void> fetchFriendRequests() async {
    final url = Uri.parse('${baseUrl}friend-requests/pending');
    print("Using JWT token: $jwt_token");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt_token',
          'Content-Type': 'application/json',
        },
      );

      print("Friend request response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friendRequests = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print('Failed to load friend requests - Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching friend requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleFriendRequest(int requestId, bool accept) async {
    final action = accept ? 'accept' : 'reject';
    final url = Uri.parse('${baseUrl}friend-requests/$action/$requestId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $jwt_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          friendRequests.removeWhere((req) => req['id'] == requestId);
        });
        print('Successfully ${action}ed request ID: $requestId');
      } else {
        print('Failed to $action request ID: $requestId - Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending $action request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : friendRequests.isEmpty
              ? Center(child: Text("No pending friend requests"))
              : ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    final senderName = request['users_friendrequest_sender_idTousers']?['displayName'] ?? 'Unknown Sender';
                    final requestId = request['id'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('👤 $senderName sent you a friend request'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => handleFriendRequest(requestId, true),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => handleFriendRequest(requestId, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
