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
    return Scaffold(
      body: 
      
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // logo
             Image.asset(
              'assets/logo2.png', 
              height: 110,
              width: 110, 
            ),

            // Text
            Text("Discover your inner  "),

            Text("calm, here at Calmcampus"),

            Text(""),

            Text("Sign in With"),

            SignInButton(
              Buttons.google,
            
             onPressed: (){

                signInWithGoogle();
             })



          ],

        ),
        
      ),

      
    );
  }

 
}

String? userName;

 signInWithGoogle() async
  {

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
   
   AuthCredential credential = GoogleAuthProvider.credential(
    accessToken:googleAuth?.accessToken ,
    idToken: googleAuth?.idToken
   );

  UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

   String? idToken = await userCredential.user?.getIdToken();

    // Print the user's display name and Firebase ID token
    userName = userCredential.user?.displayName;
    print("User Name: $userName");
    print("Firebase ID Token: $idToken");
  } 
  
