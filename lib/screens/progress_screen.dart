import 'dart:convert';
import 'package:calmcampus/Contents/appbar.dart';
import 'package:calmcampus/subScreens/streak_screen.dart';
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
  int streakDays = 4;
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
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
      });

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
        isLoading = false;
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
          streakDays = data['streakDays'] ?? 4;
        });
      }
    } catch (error) {
      print('Error fetching streak: $error');
      setState(() {
        streakDays = 4;
      });
    } finally {
      setState(() {
        isLoading = false;
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
          appBar: CommonAppBar(),
          drawer: CustomDrawer(),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressBar('Reading Progression', progressData['Reading_Progression']!, 0xFFFF8282),
                      _buildProgressBar('New Connections', progressData['New_Connections']!, 0xFFA2D897),
                      _buildProgressBar('Social Interactions', progressData['Social_Interaction']!, 0xFF95E7FE),
                      _buildProgressBar('Chat Interactions', progressData['Chat_Interactions']!, 0xFFFCAD5E),
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

Widget _buildStreakSection(BuildContext context) {
  return Column(
    children: [
      Center(
        child: Image.asset(
          'assets/Misc/Fire_streak.png',
          width: 125,
          height: 125,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            streakDays.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
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
          Navigator.pushNamed(
            context,
            '/streak',
          );
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