import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/screens/account_screen.dart';
import 'package:lucky_draw_dashboard/admin/screens/qr_screen.dart';
import 'package:lucky_draw_dashboard/admin/screens/read_users_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0; // State variable to track selected tab

  // List of pages to navigate to
  final List<Widget> _pages = [
    const QrScreens(),
    const UsersScreen(),
    const AccountScreen(),
  ];

  // Method to handle side navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      body: Row(
        children: [
          // NavigationRail sidebar
          SizedBox(height: 100),
          NavigationRail(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all, // Show labels by default
            selectedIconTheme: IconThemeData(color: Colors.red[400]),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: TextStyle(color: Colors.red[400]),
            indicatorColor: Colors.transparent,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.qr_code),
                label: Text('QR Codes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_circle),
                label: Text('Profile'),
              ),
            ],
          ),
          // Main content area
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
