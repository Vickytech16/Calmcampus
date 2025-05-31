import 'package:calmcampus/Contents/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/utilities/user_data.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, LatLng> countryCoordinates = {
  "India": LatLng(20.5937, 78.9629),
  "USA": LatLng(37.0902, -95.7129),
  "Germany": LatLng(51.1657, 10.4515),
  "UK": LatLng(55.3781, -3.4360),
  "Canada": LatLng(56.1304, -106.3468),
  "Australia": LatLng(-25.2744, 133.7751),
  "France": LatLng(46.6034, 1.8883),
  "Japan": LatLng(36.2048, 138.2529),
  "China": LatLng(35.8617, 104.1954),
  "Pakistan": LatLng(30.3753, 69.3451),
  "Bangladesh": LatLng(23.6850, 90.3563),
  "Mexico": LatLng(23.6345, -102.5528),
  "Brazil": LatLng(-14.2350, -51.9253),
  "Russia": LatLng(61.5240, 105.3188),
  "Italy": LatLng(41.8719, 12.5674),
  "South Korea": LatLng(35.9078, 127.7669),
  "Spain": LatLng(40.4637, -3.7492),
  "South Africa": LatLng(-30.5595, 22.9375),
  "Indonesia": LatLng(-0.7893, 113.9213),
  "Saudi Arabia": LatLng(23.8859, 45.0792),
  "Argentina": LatLng(-38.4161, -63.6167),
  "Turkey": LatLng(38.9637, 35.2433),
  "Nigeria": LatLng(9.0820, 8.6753),
  "Vietnam": LatLng(14.0583, 108.2772),
  "Thailand": LatLng(15.8700, 100.9925),
  "Philippines": LatLng(13.4125, 122.5600),
  "Malaysia": LatLng(4.2105, 101.9758),
  "Ukraine": LatLng(48.3794, 31.1656),
  "Netherlands": LatLng(52.1326, 5.2913),
  "Poland": LatLng(51.9194, 19.1451),
  "Egypt": LatLng(26.8206, 30.8025),
  "Iran": LatLng(32.4279, 53.6880),
  "Iraq": LatLng(33.2232, 43.6793),
  "Colombia": LatLng(4.5709, -74.2973),
  "Kenya": LatLng(-0.0236, 37.9062),
  "Ethiopia": LatLng(9.1450, 40.4897),
};


  List<Map<String, String>> selectedCountryUsers = [];
  Map<String, bool> requestSentStatus = {};
  String selectedCountry = "";
  bool showMap = false;
  bool showFriendsOnly = false;

  final String senderId = "B2OLqMyq7zVgXyctYwruJVo5cQb2"; // You can also fetch dynamically

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      final endpoint = showFriendsOnly ? 'friend-requests/friends' : 'users';
      final url = Uri.parse('${baseUrl}$endpoint');
      final headers = {
        "Authorization": "Bearer $jwt_token",
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          selectedCountry = "";
          selectedCountryUsers = data.map<Map<String, String>>((user) {
            return {
              "id": user["user_id"] ?? "",
              "name": user["displayName"] ?? "",
              "country": user["country"] ?? "Unknown",
              "photoUrl": user["photoUrl"] ?? "",
            };
          }).toList();
          requestSentStatus.clear();
          showMap = true;
        });
      } else {
        throw Exception("Failed to load users/friends");
      }
    } catch (e) {
      print("❌ Error fetching users/friends: $e");
      setState(() {
        showMap = true;
        selectedCountryUsers = [];
      });
    }
  }

  Future<void> fetchCountryUsers(String country) async {
    final modePath = showFriendsOnly ? "friends" : "users";
    final endpoint = '${baseUrl}maps/$modePath/country/$country';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $jwt_token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          selectedCountry = country;
          selectedCountryUsers = data.map<Map<String, String>>((user) {
            return {
              "id": user["user_id"] ?? "",
              "name": user["displayName"] ?? "",
              "country": user["country"] ?? "Unknown",
              "photoUrl": user["photoUrl"] ?? "",
            };
          }).toList();
          requestSentStatus.clear();
        });
      } else {
        throw Exception("Failed to fetch $modePath for $country");
      }
    } catch (e) {
      print("❌ Error fetching users/friends by country: $e");
      setState(() {
        selectedCountry = country;
        selectedCountryUsers = [];
      });
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}friend-requests/send'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwt_token",
        },
        body: jsonEncode({
          "senderId": senderId,
          "receiverId": receiverId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          requestSentStatus[receiverId] = true;
        });
        print("✅ Friend request sent.");
      } else {
        print("❌ Failed to send friend request: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending friend request: $e");
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
                              fetchAllUsers();
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
                                        country,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCountry.isEmpty
                          ? (showFriendsOnly ? 'Your Friends' : 'All Users')
                          : '${showFriendsOnly ? "Friends" : "Users"} in $selectedCountry',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text('All'),
                        Switch(
                          value: showFriendsOnly,
                          onChanged: (value) {
                            setState(() {
                              showFriendsOnly = value;
                              selectedCountry = "";
                              selectedCountryUsers = [];
                              fetchAllUsers();
                            });
                          },
                        ),
                        Text('Friends'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: selectedCountryUsers.isEmpty
                    ? Center(child: Text("No users to display"))
                    : ListView.builder(
                        itemCount: selectedCountryUsers.length,
                        itemBuilder: (context, index) {
                          final user = selectedCountryUsers[index];
                          final receiverId = user["id"]!;
                          final isRequestSent = requestSentStatus[receiverId] ?? false;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, color: Colors.black54),
                            ),
                            title: Text(user["name"] ?? ""),
                            subtitle: Text(user["country"] ?? ""),
                            trailing: ElevatedButton(
                              onPressed: isRequestSent ? null : () => sendFriendRequest(receiverId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRequestSent
                                    ? Colors.grey
                                    : Color.fromRGBO(255, 160, 122, 1),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isRequestSent ? "Requested" : "Request"),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
