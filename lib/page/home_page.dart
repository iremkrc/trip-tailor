import 'package:flutter/material.dart';
import 'package:project/page/closet_page.dart';
import 'package:project/page/profile_page.dart';
import 'package:project/page/trip_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  final List<Widget> _pages = [
    const TripPage(),
    const ClosetPage(),
    // const NotificationPage(),
    const ProfilePage(),
    // const WeatherPage(),
  ];

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedTabIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Trips',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.luggage),
          //   label: 'Packing',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.notifications),
          //   label: 'Notifications',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.sunny),
          //   label: 'Weather',
          // ),
        ],
        currentIndex: _selectedTabIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}
