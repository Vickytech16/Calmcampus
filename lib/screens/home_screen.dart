
import 'package:calmcampus/Contents/Drawer.dart';
import 'package:calmcampus/main.dart';
import 'package:calmcampus/screens/login_screen.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
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

    drawer: CustomDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Hello $userName',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Thriving starts with a calm mindset'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
              
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(20),
                
                crossAxisCount: 1,
                childAspectRatio: 4, 
    children: [
        _buildCard(text: 'Progress Bar', imagePath: 'assets/Home cards/green image.png',  gradientColors: [Color(0xFFB2DBC7), Color(0xFF51A2A3)], stops: [0, 1], customIconPath: 'assets/Icons/progress_card.png', tabIndex: 1, context: context),
        _buildCard(text: 'Contacts', imagePath: 'assets/Home cards/orange image.png', gradientColors: [Color(0xFFFFC099), Color(0xFFFF9958)], stops: [0,1], customIconPath: 'assets/Icons/contacts_card.png', tabIndex: 2, context: context),
        _buildCard(text: 'Trending articles',  imagePath: 'assets/Home cards/purple image.png', gradientColors: [Color(0xFFD8C2E3), Color(0xFF9960B4)], stops: [0,1], customIconPath: 'assets/Icons/articles_card.png', tabIndex: 5, context: context),
        _buildCard(text: 'Global Map', imagePath: 'assets/Home cards/blue image.png', gradientColors: [Color(0xFF99DBED), Color(0xFF1685BE)], stops: [0,1], customIconPath: 'assets/Icons/map_card.png', tabIndex: 3, context: context)

    ],
              ),
            ),
          ],
        ),
      ),
    );
  }


Widget _buildCard({
  required BuildContext context, // Add context here
  required String text,
  required String customIconPath,
  required String imagePath,
  required List<Color> gradientColors,
  required List<double> stops,
  required int tabIndex, // Add tabIndex for navigation
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabScreen(initialIndex: tabIndex), // Pass tabIndex
        ),
      );
    },
    
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: 94,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                stops: stops,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Icon
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Image.asset(
                    customIconPath,
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),
                ),
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 40,
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                // Text
                Expanded(
                  child: RichText(
                    text: _formatText(text),
                  ),
                ),
              ],
            ),
          ),
          // Image on top-right
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              imagePath,
              width: 150,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    ),
  );
}

TextSpan _formatText(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}