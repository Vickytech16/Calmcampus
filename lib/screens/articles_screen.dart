import 'dart:convert';
import 'package:calmcampus/subScreens/Individual_articles_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final String apiUrl = "http://localhost:3000/articles/";
  Map<String, List<Article>> articlesByCategory = {};

  final List<String> categories = [
    "Meditation",
    "Healthy hobbies",
    "Benefits of sleep",
    "Social interactions"
  ];

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        Map<String, List<Article>> tempArticles = {};

        for (String category in categories) {
          tempArticles[category] = data
              .where((article) => article['category'] == category)
              .map((article) => Article(
                    id: article['id'], // Added article ID
                    category: article['category'],
                    imageUrl: article['imageUrl'] ??
                        'assets/Misc/articles_default.png',
                    description: article['description'] ??
                        "Know how to meditate in our article",
                  ))
              .toList();
        }

        setState(() {
          articlesByCategory = tempArticles;
        });
      } else {
        setDefaultArticles();
      }
    } catch (e) {
      setDefaultArticles();
    }
  }

  void setDefaultArticles() {
    Map<String, List<Article>> defaultArticles = {};
    for (String category in categories) {
      defaultArticles[category] = List.generate(
        4,
        (index) => Article(
          id: index.toString(),
          category: category,
          imageUrl: 'assets/Misc/articles_default.png',
          description: "Know how to meditate in our article",
        ),
      );
    }

    setState(() {
      articlesByCategory = defaultArticles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: const Color.fromRGBO(255, 218, 185, 1),
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
                  TextSpan(
                      text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'alm ', style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'C', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'ampus', style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: categories
              .map((category) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: articlesByCategory[category]
                                  ?.map((article) => buildArticleBox(article))
                                  .toList() ??
                              [],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget buildArticleBox(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualArticlesScreen(articleId: article.id),
          ),
        );
      },
      child: Container(
        width: 125,
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
          children: [
            Container(
              height: 77,
              width: 116,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: article.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(article.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: article.imageUrl.isEmpty
                    ? Colors.grey[300]
                    : Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Article {
  final String id;
  final String category;
  final String imageUrl;
  final String description;

  Article({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.description,
  });
}

// New screen to display article details

