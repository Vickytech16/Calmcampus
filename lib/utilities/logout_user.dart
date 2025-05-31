import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:calmcampus/screens/login_screen.dart';
import 'package:calmcampus/utilities/user_data.dart';

Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Clear SharedPreferences
  await prefs.remove('userName');
  await prefs.remove('userEmail');
  await prefs.remove('jwt_token');
  await prefs.remove('userId');
  await prefs.remove('userCountry');

  // Reset global variables
  userNameGlobal = '';
  userEmailGlobal = '';
  jwt_token = '';
  userIdGlobal = '';
  userCountry = '';

  // Firebase and Google Sign-Out
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  // Navigate to LoginScreen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}
