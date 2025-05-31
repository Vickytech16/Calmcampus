import 'package:calmcampus/Contents/Tabs.dart';
import 'package:calmcampus/firebase_options.dart';
import 'package:calmcampus/screens/articles_screen.dart';
import 'package:calmcampus/screens/chat_screen.dart';
import 'package:calmcampus/screens/events_screen.dart';
import 'package:calmcampus/screens/map_screen.dart';
import 'package:calmcampus/screens/progress_screen.dart';
import 'package:calmcampus/screens/login_screen.dart';
import 'package:calmcampus/screens/home_screen.dart';
import 'package:calmcampus/subScreens/Individual_articles_screen.dart';
import 'package:calmcampus/subScreens/Individual_events_screen.dart';
import 'package:calmcampus/subScreens/profile_screen.dart';
import 'package:calmcampus/subScreens/streak_screen.dart';
import 'package:calmcampus/subScreens/country_selector_screen.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(CalmCampusApp());
}

class CalmCampusApp extends StatelessWidget {
  const CalmCampusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontWeight: FontWeight.w500),
          bodySmall: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const LoginScreen();
            } else {
              return FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, prefsSnapshot) {
                  if (!prefsSnapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final prefs = prefsSnapshot.data!;
                  final justLoggedIn = prefs.getBool('justLoggedIn') ?? false;

                  if (justLoggedIn) {
                    prefs.setBool('justLoggedIn', false); // Reset the flag
                    return const CountrySelectorScreen();
                  }

                  return const TabScreen(); // Default after login
                },
              );
            }
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      routes: {
        '/home': (context) =>  HomeScreen(),
        '/login': (context) =>  LoginScreen(),
        '/tabs': (context) =>  TabScreen(),
        '/progress': (context) =>  ProgressScreen(),
        '/chat': (context) =>  ChatScreen(),
        '/maps': (context) =>  MapScreen(),
        '/events': (context) =>  EventsScreen(),
        '/articles': (context) =>  ArticlesScreen(),
        '/individual_events': (context) =>  IndividualEventsScreen(eventId: '1'),
        '/Indvidual_articles': (context) =>  IndividualArticlesScreen(articleId: '1'),
        '/Profile': (context) => ProfileScreen(userEmail: userEmailGlobal),
        '/streak': (context) =>  StreakScreen(),
      },
    );
  }
}
