import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calmcampus/Contents/Drawer.dart';
import 'dart:async';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, double> progressData = {
    'Reading_Progression': 0.5,
    'New_Connections': 0.5,
    'Social_Interaction': 0.5,
    'Chat_Interactions': 0.5,
  };
  bool isLoading = true;
  int streakDays = 4;  // Default streak value
  Timer? usageTimer;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
    fetchStreakData();
    startUsageTimer();
  }

  Future<void> fetchProgressData() async {
    final url = Uri.parse('http://localhost:3000/progress/1');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          progressData = {
            'Reading_Progression': (data['Reading_Progression'] ?? 0.5).toDouble(),
            'New_Connections': (data['New_Connections'] ?? 0.5).toDouble(),
            'Social_Interaction': (data['Social_Interaction'] ?? 0.5).toDouble(),
            'Chat_Interactions': (data['Chat_Interactions'] ?? 0.5).toDouble(),
          };
        });
      }
    } catch (error) {
      print('Error fetching progress: $error');
    } finally {
      setState(() {
        isLoading = false;  // Set isLoading to false after attempting the fetch
      });
    }
  }

  Future<void> fetchStreakData() async {
    final url = Uri.parse('http://localhost:3000/streaks?userId=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          streakDays = data['streakDays'] ?? 4;  // Default to 4 if the server fails
        });
      }
    } catch (error) {
      print('Error fetching streak: $error');
      // Use default streak value in case of an error
      setState(() {
        streakDays = 4;
      });
    } finally {
      setState(() {
        isLoading = false;  // Set isLoading to false after attempting the fetch
      });
    }
  }

  Future<void> updateStreak() async {
    final url = Uri.parse('http://localhost:3000/streaks/track');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        fetchStreakData();
      }
    } catch (error) {
      print('Error updating streak: $error');
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Color.fromRGBO(255, 218, 185, 1),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 16),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset('assets/brain_icon.png'),
            ),
            SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'Karma'),
                children: [
                  TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'alm ', style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'ampus', style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar('Reading Progression', progressData['Reading_Progression']!, 0xFFFF8282),
                  _buildProgressBar('New Connections', progressData['New_Connections']!, 0xFFA2D897),
                  _buildProgressBar('Social Interactions', progressData['Social_Interaction']!, 0xFF95E7FE),
                  _buildProgressBar('Chat Interactions', progressData['Chat_Interactions']!, 0xFFFCAD5E),
                  SizedBox(height: 10),
                  _buildStreakSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressBar(String title, double value, int color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
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

  Widget _buildStreakSection() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/Misc/Fire_streak.png',
            width: 125,
            height: 125,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              streakDays.toString(),
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Day", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Streak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
