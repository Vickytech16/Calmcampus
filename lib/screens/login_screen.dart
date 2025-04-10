import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        // ✅ Background image
        Positioned.fill(
          child: Image.asset(
            'assets/Misc/background.png',
            fit: BoxFit.cover,
          ),
        ),

        // ✅ Login UI over the background
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo2.png',
                    height: 110,
                    width: 110,
                  ),

                  const SizedBox(height: 20),

                  // Taglines
                  const Text(
                    "Discover your inner",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "calm, here at Calmcampus",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 30),

                  // Label
                  const Text(
                    "Sign in with",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),

                  const SizedBox(height: 10),

                  // Google Sign-In Button
                  SignInButton(
                    Buttons.google,
                    onPressed: () {
                      signInWithGoogle();
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
}

String? userName;

Future<void> signInWithGoogle() async {
  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  String? idToken = await userCredential.user?.getIdToken();

  userName = userCredential.user?.displayName;
  print("User Name: $userName");
  print("Firebase ID Token: $idToken");
}
