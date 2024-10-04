import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Function(int) onGetStartedPressed;

  const HomePage({super.key, required this.onGetStartedPressed});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? qrCodeImage;
  List<Map<String, dynamic>> lastContacts = [];


  @override
  void initState() {
    super.initState();
    _fetchQRCode();
    _fetchLastContacts();
  }

  Future<void> _fetchQRCode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('contact_profiles');
    List<Map<String, dynamic>> profiles = [];

    // Decode stored profiles
    if (profilesJson != null) {
      final decodedProfiles = json.decode(profilesJson);
      if (decodedProfiles is List) {
        profiles = List<Map<String, dynamic>>.from(decodedProfiles);
      }
    }

    if (profiles.isNotEmpty) {
      final profile = profiles.last;
      const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
      final String url = '$baseUrl/contact-profiles/${profile['id']}/qr-code';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Map<String, dynamic> qrCodeResponse = json.decode(response.body);
          final String base64String = qrCodeResponse['image_data'];
          setState(() {
            qrCodeImage = base64Decode(base64String); // Save the QR code image
          });
        }
      } catch (e) {
        print('Error fetching QR code: $e');
      }
    }
  }

  Future<void> _fetchLastContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('saved_contacts');
    if (contactsJson != null) {
      final List<dynamic> contacts = json.decode(contactsJson);
      // Get the last three contacts
      setState(() {
        lastContacts = List<Map<String, dynamic>>.from(contacts).reversed.take(3).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          HeroSection(onGetStartedPressed: widget.onGetStartedPressed),
          const SizedBox(height: 10),
          FeaturesSection(qrCodeImage: qrCodeImage, lastContacts: lastContacts), // Pass last contacts here
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final Function(int) onGetStartedPressed;

  const HeroSection({super.key, required this.onGetStartedPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome to QrShare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'One Stop For Contact Sharing',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onGetStartedPressed(2); // Change index to desired value
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFE5D2B0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, color: Color(0xFF252728)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final Uint8List? qrCodeImage;
  final List<Map<String, dynamic>> lastContacts;

  const FeaturesSection(
      {super.key, this.qrCodeImage, required this.lastContacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .secondaryHeaderColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme
                  .of(context)
                  .cardColor,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (qrCodeImage != null) _buildQRCodeSection(context),

                  if (qrCodeImage != null)
                    _buildLastContactsSection(context),
                  if (qrCodeImage == null)
                    FeatureItem(
                      icon: Icons.qr_code,
                      title: 'Loading Your Lastest Profile',
                      onTap: () => _showQRCodeDialog(context),
                    ),
                  if (qrCodeImage == null)
                    FeatureItem(
                      icon: Icons.analytics,
                      title: 'Loading Your Lastest Saved Contacts',
                      onTap: () => _showAnalytics(context),
                    ),
                  if (qrCodeImage == null)
                    FeatureItem(
                      icon: Icons.settings,
                      title: 'Loading Count of Your Profiles and Saved Contacts',
                      onTap: () => _showCustomization(context),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      children: [
         Text(
          'Loading your QR code...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const CircularProgressIndicator(), // Show a loading indicator
      ],
    );
  }

  Widget _buildLastContactsSection(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme
              .of(context)
              .primaryColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // Add padding for better spacing
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min size to fit content
          children: [
             Text(
              'Last Saved Contacts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded( // Use Expanded to handle overflow
              child: SingleChildScrollView( // Wrap in SingleChildScrollView
                child: Column(
                  children: lastContacts.take(3).map((contact) {
                    // Prepare a string that contains all phone numbers
                    String phoneNumbers = (contact['phone_numbers'] as List<
                        dynamic>?)
                        ?.map((phone) => phone['number'])
                        .join(', ') ?? 'No Phone';

                    return ListTile(
                      title: Text(contact['name'] ?? 'No Name'),
                      subtitle: Text(phoneNumbers),
                      leading: Icon(Icons.contact_phone),
                      onTap: () {
                        // Handle tap on contact
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQRCodeSection(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme
              .of(context)
              .primaryColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // Add padding for better spacing
        child: SingleChildScrollView( // Wrap in SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use min size to fit content
            children: [
               Text(
                'Your Latest Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height * 0.70, // 70% of the screen height
                  maxWidth: MediaQuery
                      .of(context)
                      .size
                      .width * 0.70, // 70% of the screen width
                ),
                child: Image.memory(
                  qrCodeImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 100); // Default error icon
                  },
                ),
              ),
              const SizedBox(height: 20), // Add some spacing
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQRCodeDialog(BuildContext context) async {
    // Your existing implementation here...
  }

  Future<void> _showAnalytics(BuildContext context) async {
    // Your existing implementation here...
  }

  Future<void> _showCustomization(BuildContext context) async {
    // Your existing implementation here...
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: const Color(0xFF252728)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF252728)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'What Our Users Say',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 10),
          const TestimonialItem(
            feedback: 'QrShare is amazing! It has made managing QR codes so easy.',
            user: 'John Doe',
          ),
          const TestimonialItem(
            feedback: 'A must-have tool for any business!',
            user: 'Jane Smith',
          ),
        ],
      ),
    );
  }
}

class TestimonialItem extends StatelessWidget {
  final String feedback;
  final String user;

  const TestimonialItem({super.key, required this.feedback, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Color(0xFF252728),
          width: 2,
        ),
      ),
      child: ListTile(
        title: Text(
          feedback,
          style: const TextStyle(color: Color(0xFF252728)),
        ),
        subtitle: Text(
          '- $user',
          style: const TextStyle(color: Color(0xFF252728)),
        ),
      ),
    );
  }
}