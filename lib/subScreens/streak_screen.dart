import 'package:calmcampus/utilities/user_data.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:calmcampus/Contents/Drawer.dart';
import 'package:calmcampus/Contents/appbar.dart';
import 'package:calmcampus/utilities/api_check.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  Set<DateTime> streakDates = {};
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    updateStreak();
  }

  Future<void> updateStreak() async {
    try {
      // 1. Track streak
      print('Calling POST: ${baseUrl}streaks/track');
      final trackResponse = await http.post(
        Uri.parse('${baseUrl}streaks/track'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt_token',
        },
        body: jsonEncode({'userId': userIdGlobal}),
      );

      if (trackResponse.statusCode != 200) {
        print('Failed to track streak: ${trackResponse.body}');
        return;
      }

      // 2. Fetch streaks
      final streaksResponse = await http.get(
        Uri.parse('${baseUrl}streaks?userId=$userIdGlobal'),
        headers: {
          'Authorization': 'Bearer $jwt_token',
        },
      );

      if (streaksResponse.statusCode == 200) {
        final data = jsonDecode(streaksResponse.body);
        print(streaksResponse.body);

        if (data is Map<String, dynamic> && data.containsKey('streakDates')) {
          final List<dynamic> dates = data['streakDates'];
          final Set<DateTime> parsedDates = dates
              .map((d) => DateTime.parse(d).toLocal())
              .map((d) => DateTime(d.year, d.month, d.day))
              .toSet();
          setState(() {
            streakDates = parsedDates;
          });
        } else {
          print('Unexpected streak format: $data');
        }
      } else {
        print('Error fetching streak: ${streaksResponse.body}');
      }
    } catch (e) {
      print('Exception fetching streak: $e');
    }
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
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
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
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'Karma'),
                    children: [
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'alm '),
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'ampus'),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          drawer: CustomDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: today,
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black),
                outsideTextStyle: const TextStyle(color: Colors.grey),
                todayDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final dateOnly = DateTime(day.year, day.month, day.day);
                  final isStreakDay = streakDates.contains(dateOnly);

                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isStreakDay ? Colors.orange : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
              selectedDayPredicate: (day) => false,
              onDaySelected: (_, __) {},
            ),
          ),
        ),
      ],
    );
  }
}
