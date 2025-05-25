import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
