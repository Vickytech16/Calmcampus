import 'dart:convert';
import 'package:calmcampus/screens/home_screen.dart';
import 'package:calmcampus/utilities/user_data.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountrySelectorScreen extends StatefulWidget {
  const CountrySelectorScreen({super.key});

  @override
  State<CountrySelectorScreen> createState() => _CountrySelectorScreenState();
}

class _CountrySelectorScreenState extends State<CountrySelectorScreen> {
  String? selectedCountry;
  List<String> countries = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final url = Uri.parse('https://restcountries.com/v3.1/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> countryNames = data
            .map((country) => country['name']['common'] as String)
            .toList();
        countryNames.sort();
        setState(() {
          countries = countryNames;
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch countries: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching countries: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> submitCountry() async {
    if (selectedCountry == null) return;

    setState(() => isSubmitting = true);
    userCountry = selectedCountry!;
    await saveUserData();

    final url = Uri.parse('${baseUrl}users/$userIdGlobal/country');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt_token',
        },
        body: jsonEncode({'country': userCountry}),
      );

      if (response.statusCode == 200) {
        print("✅ Country updated successfully");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomeScreen()),
        );
      } else {
        print("❌ Error updating country: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception updating country: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Country')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    hint: const Text('Choose your country'),
                    onChanged: (value) =>
                        setState(() => selectedCountry = value),
                    items: countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitCountry,
                    child: isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Submit"),
                  ),
                ],
              ),
            ),
    );
  }
}
