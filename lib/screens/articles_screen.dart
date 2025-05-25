import 'package:calmcampus/utilities/api_check.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calmcampus/subScreens/Individual_articles_screen.dart';
import 'package:calmcampus/Contents/Drawer.dart';

// Replace with your actual base URL

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late Future<List<Article>> articlesFuture;

  @override
  void initState() {
    super.initState();
    articlesFuture = fetchArticles();
  }

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse('${baseUrl}articles'));

    print("API Response: ${response.body}"); // ✅ Print to CMD

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
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
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
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
          body: FutureBuilder<List<Article>>(
            future: articlesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No articles found."));
              }

              final articles = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: articles.map((article) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IndividualArticlesScreen(articleId: article.id),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.asset(
                                  'assets/Misc/articles_default.png',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  article.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ✅ Article model
class Article {
  final String id;
  final String description;

  Article({required this.id, required this.description});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'].toString(),
      description: json['description'] ?? 'No Description',
    );
  }
}
