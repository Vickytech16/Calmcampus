import 'package:calmcampus/utilities/user_data.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  DateTime? dob;
  String? selectedCountry;
  final List<String> countries = ['India', 'USA', 'Germany', 'UK', 'Australia'];

  void _pickDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  void _editName() {
    TextEditingController controller = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                name = controller.text;
                userNameGlobal = name;
              });
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  void _saveProfile() {
    if (name.isNotEmpty && dob != null && selectedCountry != null) {
      // Perform save to DB or localStorage if needed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile saved successfully!"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.redAccent,
      ));
    }
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
          extendBody: true,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Icon(Icons.notifications, color: Colors.black),
              SizedBox(width: 16),
            ],
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 30, height: 30, child: Image.asset('assets/brain_icon.png')),
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
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Your Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name.isEmpty ? "Set your name" : name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _editName,
                          child: Text("✏️", style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(widget.userEmail, style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Birth:", style: TextStyle(fontSize: 18)),
                        TextButton.icon(
                          onPressed: _pickDOB,
                          icon: Icon(Icons.calendar_month),
                          label: Text(dob == null
                              ? "Select Date"
                              : "${dob!.day}/${dob!.month}/${dob!.year}"),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Country:", style: TextStyle(fontSize: 18)),
                        DropdownButton<String>(
                          value: selectedCountry,
                          hint: Text("Select Country"),
                          items: countries.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCountry = value;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF715D49),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                      child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
