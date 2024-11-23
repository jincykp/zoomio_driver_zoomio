// bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;
  final List<Widget> pages;

  const BottomNavBar({
    Key? key,
    required this.onTabSelected,
    required this.currentIndex,
    required this.pages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onTabSelected(index);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => pages[index]),
        );
      },
      currentIndex: currentIndex,
      backgroundColor: const Color.fromARGB(255, 1, 1, 19),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(255, 73, 70, 70),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.wallet_travel), label: "Trips"),
        BottomNavigationBarItem(
            icon: Icon(Icons.card_travel), label: "Past Trips"),
        BottomNavigationBarItem(icon: Icon(Icons.image), label: "Memories"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
