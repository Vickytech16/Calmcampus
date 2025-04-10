import 'package:calmcampus/Contents/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, LatLng> countryCoordinates = {
    "India": LatLng(20.5937, 78.9629),
    "USA": LatLng(37.0902, -95.7129),
    "Germany": LatLng(51.1657, 10.4515),
  };

  Map<String, int> userCounts = {};
  List<Map<String, String>> selectedCountryUsers = [];
  Map<String, bool> requestSentStatus = {};
  String selectedCountry = "";
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    fetchUserCounts();

    // ✅ Show 4 default friends initially
    selectedCountryUsers = [
      {"name": "John Doe", "country": "Global", "id": "1"},
      {"name": "Alice Smith", "country": "Global", "id": "2"},
      {"name": "Bob Johnson", "country": "Global", "id": "3"},
      {"name": "Emma Brown", "country": "Global", "id": "4"},
    ];
  }

  Future<void> fetchUserCounts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/maps/user-density'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Map<String, int> filteredUserCounts = {};
        for (var entry in data.entries) {
          String country = extractCountryName(entry.key);
          if (country.isNotEmpty) {
            filteredUserCounts[country] =
                ((filteredUserCounts[country] ?? 0) + entry.value).toInt();
          }
        }
        setState(() {
          userCounts = filteredUserCounts;
          showMap = true;
        });
      } else {
        throw Exception("Failed to load user density");
      }
    } catch (e) {
      print("Server error: $e");
      setState(() {
        showMap = true;
        userCounts = {"India": 2};
      });
    }
  }

  String extractCountryName(String location) {
    List<String> knownCountries = countryCoordinates.keys.toList();
    for (String country in knownCountries) {
      if (location.toLowerCase().contains(country.toLowerCase())) {
        return country;
      }
    }
    return "";
  }

  Future<void> fetchCountryUsers(String country) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/maps/country/$country'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          selectedCountry = country;
          selectedCountryUsers = List<Map<String, String>>.from(data);
          requestSentStatus.clear();
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      print("Error fetching country users: $e");

      // ✅ Default fallback friends list
      setState(() {
        selectedCountry = country;
        selectedCountryUsers = [
          {"name": "John Doe", "country": country.isNotEmpty ? country : "Global", "id": "1"},
          {"name": "Alice Smith", "country": country.isNotEmpty ? country : "Global", "id": "2"},
          {"name": "Bob Johnson", "country": country.isNotEmpty ? country : "Global", "id": "3"},
          {"name": "Emma Brown", "country": country.isNotEmpty ? country : "Global", "id": "4"},
        ];
        requestSentStatus.clear();
      });
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/friend-requests/send'),
        body: jsonEncode({"userId": userId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          requestSentStatus[userId] = true;
        });
      } else {
        print("Failed to send friend request");
      }
    } catch (e) {
      print("Error sending request: $e");
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
          extendBody: true,
          drawer: CustomDrawer(),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              Icon(Icons.notifications, color: Colors.black),
              SizedBox(width: 16),
            ],
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 30, height: 30, child: Image.asset('assets/brain_icon.png')),
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
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: showMap
                    ? FlutterMap(
                        options: MapOptions(
                          center: LatLng(20, 0),
                          zoom: 2.0,
                          onTap: (_, __) {
                            setState(() {
                              selectedCountry = "";
                              selectedCountryUsers = [
                                {"name": "John Doe", "country": "Global", "id": "1"},
                                {"name": "Alice Smith", "country": "Global", "id": "2"},
                                {"name": "Bob Johnson", "country": "Global", "id": "3"},
                                {"name": "Emma Brown", "country": "Global", "id": "4"},
                              ];
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: countryCoordinates.entries.map((entry) {
                              final country = entry.key;
                              final position = entry.value;
                              final userCount = userCounts[country] ?? 0;

                              return Marker(
                                point: position,
                                width: 80,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () => fetchCountryUsers(country),
                                  child: Column(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.red, size: 40),
                                      Text(
                                        '$country ($userCount)',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCountry.isEmpty
                            ? 'Friends List'
                            : 'Users in $selectedCountry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedCountryUsers.length,
                          itemBuilder: (context, index) {
                            final user = selectedCountryUsers[index];
                            final userId = user["id"]!;
                            final isRequestSent = requestSentStatus[userId] ?? false;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.black54),
                              ),
                              title: Text(user["name"]!),
                              subtitle: Text(user["country"]!),
                              trailing: ElevatedButton(
                                onPressed:
                                    isRequestSent ? null : () => sendFriendRequest(userId),
                                child: Text(isRequestSent ? "Request Sent!" : "Request"),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
