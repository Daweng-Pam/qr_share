import 'package:flutter/material.dart';
import 'package:schoolap_push/contact.dart';
import 'package:schoolap_push/custom%20ui%20stuff/header.dart';
import 'custom ui stuff/navar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';       // HomePage
import 'profile_page.dart';
import 'scan.dart';      // ScanScreen
import 'custom ui stuff/settings.dart';  // SettingsScreen
import 'Saved_Contacts.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      HomePage(
        onGetStartedPressed: (index) {
          _onTabSelected(index);
        },
      ),
      const PersonalProfiles(),
      const Scan(),
      const SavedContacts(),
      const MyProfilePage(),
      const Settings(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    print("new index: $index");
  }

  Future<void> data() async {
    // Implement your data fetching logic here
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getProfilePhotoUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profilePhotoUrl = snapshot.data ??
            'https://www.shutterstock.com/image-vector/defaultx-avatar-profile-icon-social-600nw-1677509740.jpg';

        return Scaffold(
          appBar: Header(
            onProfileTap: (index) {
              _onTabSelected(index);
            },
            profilePhotoUrl: profilePhotoUrl,
          ),
          body: RefreshIndicator(
            onRefresh: data, // This should be a function returning a Future
            child: _screens[_selectedIndex], // This should be the widget to refresh
          ),
          bottomNavigationBar: NavBar(
            onTabSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
          ),
        );
      },
    );
  }

  Future<String?> _getProfilePhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_photo_url');
  }
}