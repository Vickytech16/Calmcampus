import 'dart:async';
import 'dart:convert';
import 'package:calmcampus/Contents/appbar.dart';
import 'package:calmcampus/Contents/Drawer.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool isLoading = true;
  int streakDays = 0;
  Timer? usageTimer;

  Map<String, double> progressData = {
    'Articles Read': 0.0,
    'New Connections': 0.0,
    'Messages Sent': 0.0,
  };

  @override
  void initState() {
    super.initState();
    fetchProgressData();
    fetchStreakData();
    startUsageTimer();
  }

  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt_token',
    };
  }

  
  Future<void> fetchProgressData() async {
  final url = Uri.parse('${baseUrl}progress/$userIdGlobal');
  try {
    final headers = getAuthHeaders();
    print("Sending request with headers: $headers");

    final response = await http.get(url, headers: headers);
    print("Status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("Response!!!!!!!!!!!!!!! == ${response.body}");
      final data = json.decode(response.body);

      // Access nested scores object
      final scores = data['scores'] ?? {};
      setState(() {
        progressData = {
          'Articles Read': ((scores['articlesRead'] ?? 0) / 10).clamp(0.0, 1.0),
          'New Connections': ((scores['newConnections'] ?? 0) / 10).clamp(0.0, 1.0),
          'Messages Sent': ((scores['messagesSent'] ?? 0) / 10).clamp(0.0, 1.0),
        };
      });
    } else {
      print("Failed to load progress: ${response.body}");
    }
  } catch (e) {
    print("Error fetching progress: $e");
  } finally {
    setState(() => isLoading = false);
  }
}



  Future<void> fetchStreakData() async {
    final url = Uri.parse('${baseUrl}streaks?userId=$userIdGlobal');
    try {
      final response = await http.get(url, headers: getAuthHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          streakDays = data['streakDays'] ?? 0;
        });
      } else {
        print("Failed to fetch streak: ${response.body}");
      }
    } catch (e) {
      print("Error fetching streak: $e");
    }
  }

  Future<void> updateStreak() async {
    final url = Uri.parse('${baseUrl}streaks/track');
    try {
      final response = await http.post(
        url,
        headers: getAuthHeaders(),
        body: jsonEncode({'userId': userIdGlobal}),
      );
      if (response.statusCode == 200) {
        fetchStreakData();
      } else {
        final msg = jsonDecode(response.body)['message'];
        print('Streak track response: $msg');
      }
    } catch (e) {
      print("Error updating streak: $e");
    }
  }

  void startUsageTimer() {
    usageTimer = Timer(Duration(minutes: 1), updateStreak);
  }

  @override
  void dispose() {
    usageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Misc/background.png', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CommonAppBar(),
          drawer: CustomDrawer(),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressBar('Articles Read', progressData['Articles Read']!, 0xFFFF8282),
                      _buildProgressBar('New Connections', progressData['New Connections']!, 0xFFA2D897),
                      _buildProgressBar('Messages Sent', progressData['Messages Sent']!, 0xFF95E7FE),
                      const SizedBox(height: 10),
                      _buildStreakSection(context),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String title, double value, int color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          color: Color(color),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Image.asset('assets/Misc/Fire_streak.png', width: 125, height: 125),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              streakDays.toString(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Day", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Streak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/streak');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Check Streak"),
        ),
      ],
    );
  }
}
