import 'package:calmcampus/screens/contact_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  toolbarHeight: 100,
  backgroundColor: Color.fromRGBO(255, 218, 185, 1),
  leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu), // Hamburger button
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Open the Drawer
        },
      ),
    ),
  actions: [
    Icon(Icons.notifications, color: Colors.black),
    SizedBox(width: 16),
  ],
  title: Row(
    mainAxisSize: MainAxisSize.min, // Ensure the title doesn't take up extra space
    children: [
      SizedBox(
        width: 30,
        height: 30,
        child: Image.asset(
          'assets/brain_icon.png',
        ),
      ),
      SizedBox(width: 8), // Space between icon and text
       RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'Karma'), 
    children: [
      TextSpan(
        text: 'C', 
        style: TextStyle(fontWeight: FontWeight.bold), 
      ),
      TextSpan(
        text: 'alm ', 
        style: TextStyle(fontWeight: FontWeight.normal), 
      ),
      TextSpan(
        text: 'C',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'ampus',
        style: TextStyle(fontWeight: FontWeight.normal)
      )
    ],
  ),
),
    ],
  ),
  centerTitle: true, // Center the title
),

    drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 150,
          child: DrawerHeader(
            
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 218, 185, 1),
            ),
            
            child: Text(
              'Calmcampus',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () async{

            await GoogleSignIn().signOut();
            FirebaseAuth.instance.signOut();
            
            print("Logout clicked");
        
          },
        ),
      ],
    ),
  ),
   
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat with Contacts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListView.builder(
  shrinkWrap: true,
  itemCount: 4,
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[700]),
        ),
        title: Text('Contact ${index + 1}'),
        subtitle: const Text('Tap to chat'),
        trailing: const Icon(Icons.chat, color: Colors.grey),
        onTap: () {
          // Navigate to ContactChatsScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactChatsScreen()),
          );
        },
      ),
    );
  },
)
,
          ],
        ),
      ),
    );
  }
}