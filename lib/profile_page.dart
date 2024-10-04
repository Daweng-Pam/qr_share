import 'package:flutter/material.dart';
import 'package:schoolap_push/settings.dart';
import 'package:schoolap_push/login_page.dart';
import 'GoogleSignIn_id.dart';
import 'custom ui stuff/List.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

final GlobalKey<LoginPageState> loginPageKey = GlobalKey<LoginPageState>();

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  MyProfilePageState createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  late Future<Map<String, String>> _profileData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    _profileData = _getProfileData();
  }


  Future<int> getNumOfContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('contact_profiles');

    if (profilesJson != null) {
      final List<dynamic> profilesList = json.decode(profilesJson);
      return profilesList.length; // Returns the number of contacts
    } else {
      return 0; // If there are no saved contacts, return 0
    }
  }

  Future<Map<String, String>> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'John Doe';
    final profilePhotoUrl = prefs.getString('profile_photo_url') ??
        'https://www.shutterstock.com/image-vector/default-avatar-profile-icon-social-600nw-1677509740.jpg';
    final profiles = await getNumOfContacts();
    return {
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'profiles': profiles.toString(),
    };
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
      debugPrint("Signed Out");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), // or another page
      );
    } catch (e) {
      showErrorDialog('Sign Out Error', 'An error occurred during sign-out: $e');
    }
  }

  void showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showError(String title, String content) => showErrorDialog(title, content);
  void signOut() => _signOut();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<Map<String, String>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile data'));
          }

          final profileData = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My Profile',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileData['profilePhotoUrl']!),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      ListTile(
                        title: const Text(
                          'NAME',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            height: 17.07 / 20,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        subtitle: Text(
                          profileData['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            fontSize: 28,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'PROFILES',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            height: 17.07 / 20,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        subtitle: Text(
                          profileData['profiles']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            fontSize: 28,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomListTile(
                        titleText: 'Personal Details',
                        onTap: () {
                          // Add navigation logic to personal details page
                        },
                        leadingIcon: Icons.account_circle,
                      ),
                      CustomListTile(
                        titleText: 'My Profiles',
                        onTap: () {
                          // Add navigation logic to my profiles page
                        },
                        leadingIcon: Icons.grid_view,
                      ),
                      CustomListTile(
                        titleText: 'Saved Contacts',
                        onTap: () {
                          // Add navigation logic to saved contacts page
                        },
                        leadingIcon: Icons.contact_mail_rounded,
                      ),
                      CustomListTile(
                        titleText: 'Settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        leadingIcon: Icons.settings,
                      ),
                      CustomListTile(
                        titleText: 'FAQs',
                        onTap: () {
                          // Add navigation logic to FAQs page
                        },
                        leadingIcon: Icons.question_mark,
                      ),
                      CustomListTile(
                        titleText: 'Terms and Conditions',
                        onTap: () {
                          // Add navigation logic to terms and conditions page
                        },
                        leadingIcon: Icons.stop_circle_outlined,
                      ),
                      CustomListTile(
                        titleText: 'Logout',
                        onTap: () {
                          try{
                            signOut();
                          }catch(e) {
                            showError('Problem Logging Out', "Please restart app");
                          }
                        },
                        leadingIcon: Icons.logout_outlined ,
                        showArrow: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
