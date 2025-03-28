// 02/01/2025

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IndividualArticlesScreen extends StatefulWidget {
  final String articleId;

  const IndividualArticlesScreen({super.key, required this.articleId});

  @override
  State<IndividualArticlesScreen> createState() => _IndividualArticlesScreenState();
}

class _IndividualArticlesScreenState extends State<IndividualArticlesScreen> {
  late Future<Article> articleFuture;

  @override
  void initState() {
    super.initState();
    articleFuture = fetchArticle(widget.articleId);
  }

  Future<Article> fetchArticle(String articleId) async {
    final String apiUrl = "http://localhost:3000/articles/$articleId";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Article(
          id: data['id'] ?? 'Unknown ID',
          title: data['title'] ?? 'Unknown Title',
          images: List<String>.from(data['images'] ?? []),
          content: data['content'] ?? '',
        );
      } else {
        print("Error: Failed to load article (Status Code: ${response.statusCode})");
      }
    } catch (e) {
      print("Error fetching article: $e");
    }
    return getDefaultArticle();
  }

  Article getDefaultArticle() {
    return Article(
      id: "",
      title: "Meditation",
      images: ['assets/Misc/articles_default.png'],
      content: '''
What is Meditation?

Meditation is the means by which we experience the love, peace, and stillness that is within ourselves. It is the process of experiencing God’s love for ourselves by taking our attention away from the world outside and focusing it within. 

Meditation is the highest form of prayer and unlocks the gates to the reservoir of untapped love that we carry with us.

Meditation Reduces Stress and Anxiety

People around the world have been turning to meditation to release stress, as research has shown that spending regular, accurate time in meditation can reduce stress and anxiety. This in turn alleviates stress-related ailments such as high blood pressure, insomnia, chronic pain, and fatigue.
      ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        toolbarHeight: 80,
        backgroundColor: const Color(0xFFFFD4B2), // Softer peach color
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.7),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.black, size: 28),
          ),
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
                style: TextStyle(
                    color: Colors.black, fontSize: 28, fontFamily: 'Karma'),
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
      body: SafeArea(
        child: FutureBuilder<Article>(
          future: articleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Loading article...",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  "Failed to load article.",
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              );
            } else {
              final article = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 16),
                    ...article.images.map(
                      (imageUrl) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Image.asset(imageUrl, height: 200, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Article {
  final String id;
  final String title;
  final List<String> images;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.images,
    required this.content,
  });
}
