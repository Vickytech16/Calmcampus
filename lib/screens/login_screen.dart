import 'dart:convert';
import 'package:calmcampus/screens/home_screen.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                crossAxisAlignment: CrossAxisAlignment.center,
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

                        String photoUrl = user.photoURL ??
                            'https://upload.wikimedia.org/wikipedia/en/9/9b/Pikachu_artwork.png';
                        String userName = user.displayName ?? 'Unknown User';

                        userIdGlobal = user.uid;

                        bool success = await sendUserToBackend(user, photoUrl, userName);

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
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

  /// 🔐 Google Sign-In and Firebase Auth
  Future<User?> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
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

      print("USER ID STORED SUCCESSFULLY: $userIdGlobal");
      final responseData = json.decode(response.body);
      jwt_token = responseData['accessToken'] ?? '';
      print("✅ JWT stored: $jwt_token");
      return true;
    } else {
      print("❌ Failed to send user data. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
      return false;
    }
  } catch (e) {
    print("❌ Exception in sendUserToBackend: $e");
    return false;
  }
}


}
