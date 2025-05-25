import 'package:calmcampus/Contents/Tabs.dart';
import 'package:calmcampus/subScreens/friend_requests.dart';
import 'package:calmcampus/subScreens/profile_screen.dart';
import 'package:calmcampus/subScreens/friends_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:calmcampus/main.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      backgroundColor: Color(0xFFD4CEBE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: DrawerHeader(
                decoration: BoxDecoration(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(''), // Placeholder
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vicky',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'vickytech16@gmail.com',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('My Profile'),
                    onTap: () {
                      Navigator.pushNamed(context, '/Profile');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.trending_up),
                    title: Text('Trending Articles'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabScreen(initialIndex: 5),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text('Upcoming Events'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabScreen(initialIndex: 4),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () async {
                      await GoogleSignIn().signOut();
                      await FirebaseAuth.instance.signOut();
                      print("Logout clicked");
                    },
                  ),
                  ListTile(
  leading: Icon(Icons.group_add),
  title: Text('Friend Requests'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendRequestsScreen(),
      ),
    );
  },
),
ListTile(
  leading: Icon(Icons.group),
  title: Text('Friends List'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsListScreen(),
      ),
    );
  },
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
