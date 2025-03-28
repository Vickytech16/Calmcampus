import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndividualEventsScreen extends StatefulWidget {
  final String eventId;

  const IndividualEventsScreen({super.key, required this.eventId});

  @override
  State<IndividualEventsScreen> createState() => _IndividualEventsScreenState();
}

class _IndividualEventsScreenState extends State<IndividualEventsScreen> {
  // Fetch event details from the API
  Future<Map<String, dynamic>> fetchEventDetails(String eventId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/events/$eventId'));

      if (response.statusCode == 200) {
        return json.decode(response.body); // Parse the JSON response
      } else {
        throw Exception('Failed to load event data');
      }
    } catch (e) {
      return {
        'name': 'Mental Health Summit',
        'date': '16/02/2025',
        'location': 'Online',
        'team': 'XYZ',
        'objective': 'An event report is a detailed summary of your event’s outcomes, covering everything from attendance and engagement to finances and marketing effectiveness. It’s a tool that allows you to analyze the event\'s success, pinpoint areas for improvement, and gather insights for future planning. It’s essential for measuring ROI and justifying the event’s value to stakeholders.'
      }; // Default values in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Color.fromRGBO(255, 218, 185, 1),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEventDetails(widget.eventId), // Fetch event data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is loading
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there is an error in fetching data
            return Center(child: Text('Failed to load event data.'));
          } else if (snapshot.hasData) {
            // If data is successfully fetched
            var eventData = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Event Title
                    Text(
                      eventData['name'] ?? 'Mental Health Summit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF775E45), // Event name color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // Event Date
                    Row(
                      children: [
                        Text(
                          'Date: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF775E45), // Bold and colored label
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          eventData['date'] ?? '16/02/2025',
                          style: TextStyle(fontSize: 16, color: Color(0xFF775E45)), // Colored value
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Event Location
                    Row(
                      children: [
                        Text(
                          'Location: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF775E45), // Bold and colored label
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          eventData['location'] ?? 'Online',
                          style: TextStyle(fontSize: 16, color: Color(0xFF775E45)), // Colored value
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Organizing Team
                    Row(
                      children: [
                        Text(
                          'Organizing Team: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF775E45), // Bold and colored label
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          eventData['team'] ?? 'XYZ',
                          style: TextStyle(fontSize: 16, color: Color(0xFF775E45)), // Colored value
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Event Objective Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Event Objective:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF775E45), // Bold and colored label
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Event Objective Content
                    Text(
                      eventData['objective'] ?? 'Default objective content',
                      style: TextStyle(fontSize: 16, color: Color(0xFF775E45)), // Colored value
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
