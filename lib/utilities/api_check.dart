import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

    final baseUrl = Uri.parse('https://619e-2401-4900-2304-788f-99e4-f969-5bd1-f1e3.ngrok-free.app/');
    String chatUrl = "https://619e-2401-4900-2304-788f-99e4-f969-5bd1-f1e3.ngrok-free.app/";


class ApiCheck extends StatefulWidget {
  const ApiCheck({super.key});

  @override
  State<ApiCheck> createState() => _ApiCheckState();
}

class _ApiCheckState extends State<ApiCheck> {
  String _response = 'Fetching...';

  @override
  void initState() {
    super.initState();
    fetchApiData();
  }

  Future<void> fetchApiData() async {

    try {
      final response = await http.get(baseUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ API Response: $data");

        setState(() {
          _response = "Response: $data";
        });
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() {
          _response = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("❌ API Exception: $e");
      setState(() {
        _response = "Failed to connect: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Check"),
      ),
      body: Center(
        child: Text(
          _response,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
