import 'package:shared_preferences/shared_preferences.dart';

String userNameGlobal = 'Defaultuser1';
String userEmailGlobal = 'Defaultmail1';
String jwt_token = '';
String userIdGlobal = '';
String userCountry = '';

Future<void> saveUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userName', userNameGlobal);
  await prefs.setString('userEmail', userEmailGlobal);
  await prefs.setString('jwtToken', jwt_token);
  await prefs.setString('userId', userIdGlobal);
  await prefs.setString('userCountry', userCountry);
}

Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  userNameGlobal = prefs.getString('userName') ?? '';
  userEmailGlobal = prefs.getString('userEmail') ?? '';
  jwt_token = prefs.getString('jwtToken') ?? '';
  userIdGlobal = prefs.getString('userId') ?? '';
  userCountry = prefs.getString('userCountry') ?? '';
}
