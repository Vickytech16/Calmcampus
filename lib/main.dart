import 'package:calmcampus/firebase_options.dart';
import 'package:calmcampus/screens/articles_screen.dart';
import 'package:calmcampus/screens/chat_screen.dart';
import 'package:calmcampus/screens/events_screen.dart';
import 'package:calmcampus/screens/map_screen.dart';
import 'package:calmcampus/screens/progress_screen.dart';
import 'package:calmcampus/subScreens/Individual_articles_screen.dart';
import 'package:calmcampus/subScreens/Individual_events_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:calmcampus/screens/login_screen.dart';
import 'package:calmcampus/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CalmCampusApp());
}

class CalmCampusApp extends StatelessWidget {
  const CalmCampusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontWeight: FontWeight.w500),
          bodySmall: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return LoginScreen();
            } else {
              return TabScreen();
            }
          }
          return LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/tabs': (context) => TabScreen(),
        '/progress': (context) => ProgressScreen(),
        '/chat': (context) => ChatScreen(),
        '/maps': (context) => MapScreen(),
        '/events': (context) => EventsScreen(),
        '/articles': (context) => ArticlesScreen(),
        '/individual_events' : (context) => IndividualEventsScreen(eventId: '1',),
        '/Indvidual_articles' : (context) => IndividualArticlesScreen(articleId: '1',)
      },
    );
  }
}


class TabScreen extends StatefulWidget {
  final int initialIndex; // New parameter for starting tab

  const TabScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    HomeScreen(),
    ProgressScreen(),
    ChatScreen(),
    MapScreen(),
    EventsScreen(),
    ArticlesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Use initial index when navigating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 75,
            decoration: BoxDecoration(
              color: Color(0xFFCBC4B6), // Background color
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (index) {
              return _buildNavItem(
                iconSelected: _getSelectedIcon(index),
                iconUnselected: _getUnselectedIcon(index),
                label: _getLabel(index),
                index: index,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconSelected,
    required String iconUnselected,
    required String label,
    required int index,
  }) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(bottom: isSelected ? 8 : 0), // Move icon up
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCBC4B6), // Same as background
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                  ),
                Image.asset(
                  isSelected ? iconSelected : iconUnselected,
                  width: 32,
                  height: 32,
                  color: isSelected ? Color(0xFF715D49) : Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: isSelected ? 4 : 0), // Adds space between icon and text
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0, // Smoothly fade in text
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // Moves text slightly up
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


String _getSelectedIcon(int index) {
  switch (index) {
    case 0:
      return 'assets/Icons/home_brown.png';
    case 1:
      return 'assets/Icons/progress_brown.png';
    case 2:
      return 'assets/Icons/contacts_brown.png';
    case 3:
      return 'assets/Icons/map_brown.png';
    case 4:
      return 'assets/Icons/events_brown.png';
    case 5:
      return 'assets/Icons/articles_brown.png';
    default:
      return 'assets/Icons/articles_brown.png';
  }
}

String _getUnselectedIcon(int index) {
  switch (index) {
    case 0:
      return 'assets/Icons/home_white.png';
    case 1:
      return 'assets/Icons/progress_white.png';
    case 2:
      return 'assets/Icons/contacts_white.png';
    case 3:
      return 'assets/Icons/map_white.png';
    case 4:
      return 'assets/Icons/events_white.png';
    case 5:
      return 'assets/Icons/articles_white.png';
    default:
      return 'assets/Icons/articles_white.png';
  }
}

String _getLabel(int index) {
  switch (index) {
    case 0: return "Home";
    case 1:
      return "Progress";
    case 2:
      return "Chat";
    case 3:
      return "Map";
    case 4:
      return "Events";
    case 5:
      return "Articles";
    default:
      return "";
  }
}

