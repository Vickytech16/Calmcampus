import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calmcampus/Contents/Drawer.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse('http://localhost:3000/events/upcoming');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          events = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (error) {
      print('Error fetching events: $error');
      setState(() {
        isLoading = false;
      });
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
          drawer: CustomDrawer(),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
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
                    style: TextStyle(
                        color: Colors.black, fontSize: 28, fontFamily: 'Karma'),
                    children: [
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'alm '),
                      TextSpan(text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'ampus', style: TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: events.isNotEmpty ? events.length : 4,
                          itemBuilder: (context, index) {
                            if (events.isNotEmpty) {
                              return GestureDetector(
                                child: _buildEventBox(
                                  events[index]['image'] ?? 'assets/Misc/Events_default.png',
                                  events[index]['description'] ?? 'No description available',
                                  events[index]['date'] ?? 'Date not available',
                                  events[index]['time'] ?? 'Time not available',
                                ),
                              );
                            } else {
                              return _buildEventBox(
                                'assets/Misc/Events_default.png',
                                'Online webinar to discuss healthy hobbies',
                                '20/12/2024',
                                '11:30 PM PST',
                              );
                            }
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventBox(String imagePath, String description, String date, String time) {
    return Container(
      width: 315,
      height: 400,
      decoration: BoxDecoration(
        color: Color(0xFFEBE4D9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 296,
                height: 179,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(description, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 14),
                    SizedBox(width: 5),
                    Text(date, style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 14),
                    SizedBox(width: 5),
                    Text(time, style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/individual_events');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 160, 122, 1),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
