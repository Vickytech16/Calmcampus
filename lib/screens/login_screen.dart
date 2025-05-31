import 'dart:convert';
import 'package:calmcampus/screens/home_screen.dart';
import 'package:calmcampus/subScreens/country_selector_screen.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    loadUserData(); // Load user data from local storage
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo2.png', height: 110, width: 110),
                  const SizedBox(height: 20),
                  const Text("Discover your inner", style: TextStyle(fontSize: 18)),
                  const Text("calm, here at Calmcampus", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  const Text("Sign in with", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  SignInButton(
                    Buttons.google,
                    onPressed: () async {
                      final user = await signInWithGoogle();
                      if (user != null) {
                        userEmailGlobal = user.email ?? '';
                        userNameGlobal = user.displayName ?? 'Unknown User';
                        userIdGlobal = user.uid;

                        String photoUrl = user.photoURL ??
                            'https://upload.wikimedia.org/wikipedia/en/9/9b/Pikachu_artwork.png';

                        bool success = await sendUserToBackend(user, photoUrl, userNameGlobal);

                        if (success) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('userEmail', userEmailGlobal);
                          await prefs.setString('userName', userNameGlobal);
                          await prefs.setString('userId', userIdGlobal);
                          await prefs.setString('jwt_token', jwt_token);

                            // ✅ Set login flag
                          await prefs.setBool('justLoggedIn', true);

                          if (!mounted) return;

                          // ✅ Always go to country selector screen after login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CountrySelectorScreen()),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<User?> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<bool> sendUserToBackend(User user, String photoUrl, String userName) async {
    final url = Uri.parse('${baseUrl}auth/login');
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": user.email ?? '',
          "user_id": user.uid,
          "picture": photoUrl,
          "name": userName,
          "fcmToken": fcmToken ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        jwt_token = responseData['accessToken'] ?? '';
        print("✅ JWT stored: $jwt_token");
        return true;
      } else {
        print("❌ Backend error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }
}
