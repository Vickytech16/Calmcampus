import 'package:flutter/material.dart';

class IndividualArticlesScreen extends StatelessWidget {
  final String articleId;
  const IndividualArticlesScreen({super.key, required this.articleId});

  Article getArticleById(String id) {
    final Map<String, Article> articles = {
      "1": Article(
        id: "1",
        title: "The Importance of Mental Health for Students",
        content: '''
Mental health is essential for every student because it affects how we think, feel, and act. Students face many challenges like exams, social pressure, and future uncertainty. These pressures can cause stress, anxiety, and even depression if not addressed properly.

When mental health is cared for, students can perform better in academics, maintain healthier relationships, and enjoy life more. Good mental health also boosts confidence and helps students stay motivated and focused in their studies.

Colleges and schools can help by offering counseling services and promoting self-care. Talking about mental health openly and seeking help when needed should be encouraged to create a safe and supportive environment for every student.
        ''',
      ),
      "2": Article(
        id: "2",
        title: "How Mindfulness Can Improve Academic Performance",
        content: '''
Mindfulness is about being fully present in the moment without being overwhelmed by thoughts. For students, practicing mindfulness can reduce exam anxiety and help improve concentration during study sessions.

Simple techniques like breathing exercises, mindful walking, or taking short breaks to clear your mind can make a big difference. When students are calm and focused, they can retain information better and perform well in class.

Schools can support this by introducing short daily mindfulness activities. Over time, students will feel more in control of their emotions and better equipped to handle academic pressure with a clear and peaceful mindset.
        ''',
      ),
      "3": Article(
        id: "3",
        title: "The Role of Peer Support in Student Mental Health",
        content: '''
Having someone to talk to who understands you is very comforting, especially in a school or college setting. Peer support means students help each other through shared experiences, offering advice or simply being there to listen.

It helps reduce feelings of loneliness and builds a sense of community. Many students find it easier to open up to friends than to adults, making peer support a valuable addition to mental health care.

Colleges can organize peer support groups or buddy systems to promote this idea. With proper training and encouragement, students can become strong pillars of support for one another, leading to a healthier and more connected campus.
        ''',
      ),
      "4": Article(
        id: "4",
        title: "Balancing Technology Use for Better Mental Well-being",
        content: '''
Technology plays a big role in our daily lives, but using it too much—especially social media—can affect our mood and mental health. Constant scrolling, comparison, and online pressure can cause stress and lower self-esteem.

Students can benefit from setting time limits on their phones, taking regular breaks, and avoiding screens before bedtime. These small steps can improve sleep, reduce anxiety, and boost focus in class.

It’s not about giving up technology but using it wisely. Doing things like reading, spending time outdoors, or talking with friends in person can help students stay balanced and happy.
        ''',
      ),
    };

    return articles[id] ?? articles["1"]!;
  }

  @override
  Widget build(BuildContext context) {
    final article = getArticleById(articleId);
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
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Article {
  final String id;
  final String title;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.content,
  });
}
