import 'package:flutter/material.dart';
import 'package:loyalty_card_app/features/card/presentation/pages/card_list_page.dart';
import 'package:loyalty_card_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:loyalty_card_app/features/settings/presentation/pages/settings_page.dart';
import 'package:loyalty_card_app/features/card/presentation/pages/add_edit_card_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CardListPage(),
    const NotificationsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditCardPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 