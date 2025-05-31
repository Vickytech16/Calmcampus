import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:calmcampus/Contents/Drawer.dart';
import 'package:calmcampus/utilities/api_check.dart';
import 'package:calmcampus/utilities/user_data.dart';

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
    final response = await http.get(
      Uri.parse('${baseUrl}articles'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt_token',
      },
    );

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<void> markArticleAsRead(String articleId) async {

    print("🔔 markArticleAsRead() called with ID: $articleId"); // <- Add this
 final response = await http.post(

  Uri.parse("${baseUrl}articles/$articleId/mark-as-read"),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwt_token',
  },
  body: json.encode({}), // 👈 try sending an empty object
);


  if (response.statusCode != 200) {
    print("Failed to mark as read: ${response.body}");
    print("ARTICLEID _>>>>>>>>>>>>>>>>>>>>>>>>> $articleId");
  } else {
    print("Article $articleId marked as read");
  }
}


Future<void> _launchURL(String url, String articleId) async {

  print("🔗 Launching URL: $url for article ID: $articleId"); // <- Add this
  await markArticleAsRead(articleId);
  

  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
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
                        onTap: () => _launchURL(article.sourceUrl, article.id),
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
                                child: Image.network(
                                  article.imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/Misc/articles_default.png',
                                          height: 150, fit: BoxFit.cover),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Category: ${article.category}',
                                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                    ),
                                  ],
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

// ✅ Updated Article model
class Article {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String sourceUrl;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.sourceUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final contents = json['contents'] ?? [];
    return Article(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      category: contents.isNotEmpty ? contents[0]['category'] ?? 'Unknown' : 'Unknown',
      imageUrl: json['image_url'] ?? '',
      sourceUrl: contents.isNotEmpty ? contents[0]['source_url'] ?? '' : '',
    );
  }
}
