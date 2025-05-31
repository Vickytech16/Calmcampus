
import 'package:calmcampus/screens/articles_screen.dart';
import 'package:calmcampus/screens/chat_screen.dart';
import 'package:calmcampus/screens/events_screen.dart';
import 'package:calmcampus/screens/home_screen.dart';
import 'package:calmcampus/screens/map_screen.dart';
import 'package:calmcampus/screens/progress_screen.dart';
import 'package:flutter/material.dart';

class TabScreen extends StatefulWidget {
  final int initialIndex;

  const TabScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<TabScreen> createState() => _TabScreenState();
}
class _TabScreenState extends State<TabScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    HomeScreen(),
    ProgressScreen(),
    ChatScreen(),
    MapScreen(),
    // EventsScreen(),
    ArticlesScreen(),
  ];

  @override
  void initState() {
    super.initState();
      _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/Misc/background.png",
              fit: BoxFit.cover,
            ),
          ),
          _screens[_currentIndex],
        ],
      ),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SizedBox(
        height: 75,
        child: Container(
          color: const Color(0xFFCBC4B6).withOpacity(0.95),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return _buildNavItem(
                iconSelected: _getSelectedIcon(index),
                iconUnselected: _getUnselectedIcon(index),
                label: _getLabel(index),
                index: index,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String iconSelected,
    required String iconUnselected,
    required String label,
    required int index,
  }) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 60,
        height: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCBC4B6),
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                  ),
                Image.asset(
                  isSelected ? iconSelected : iconUnselected,
                  width: 32,
                  height: 32,
                  color: isSelected ? const Color(0xFF715D49) : Colors.white,
                ),
              ],
            ),
            if (isSelected)
              const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


String _getSelectedIcon(int index) {
  switch (index) {
    case 0:
      return 'assets/Icons/home_brown.png';
    case 1:
      return 'assets/Icons/progress_brown.png';
    case 2:
      return 'assets/Icons/contacts_brown.png';
    case 3:
      return 'assets/Icons/map_brown.png';
    // case 4:
    //   return 'assets/Icons/events_brown.png';
    case 4:
      return 'assets/Icons/articles_brown.png';
    default:
      return 'assets/Icons/articles_brown.png';
  }
}

String _getUnselectedIcon(int index) {
  switch (index) {
    case 0:
      return 'assets/Icons/home_white.png';
    case 1:
      return 'assets/Icons/progress_white.png';
    case 2:
      return 'assets/Icons/contacts_white.png';
    case 3:
      return 'assets/Icons/map_white.png';
    // case 4:
    //   return 'assets/Icons/events_white.png';
    case 4:
      return 'assets/Icons/articles_white.png';
    default:
      return 'assets/Icons/articles_white.png';
  }
}

String _getLabel(int index) {
  switch (index) {
    case 0:
      return "Home";
    case 1:
      return "Progress";
    case 2:
      return "Chat";
    case 3:
      return "Map";
    // case 4:
    //   return "Events";
    case 4:
      return "Articles";
    default:
      return "";
  }
}