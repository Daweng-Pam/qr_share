import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Services/LoginPageService.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';


class SavedContacts extends StatefulWidget {
  const SavedContacts({Key? key}) : super(key: key);

  @override
  _SavedContactsState createState() => _SavedContactsState();
}

class _SavedContactsState extends State<SavedContacts> {
  List<Map<String, dynamic>> contacts = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  Future<void> _refreshContacts() async {
    if (userId != null) {
      await LoginPageService().getSavedContacts(userId!);
      await _loadContacts(); // Reload profiles after fetching new data
    } else {
      print('User ID is not available');
    }
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('saved_contacts');

    if (contactsJson != null) {
      final decodedContacts = json.decode(contactsJson);
      if (decodedContacts is List) {
        setState(() {
          contacts = List<Map<String, dynamic>>.from(decodedContacts);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshContacts,
        child: contacts.isEmpty
            ? const Center(child: Text('No contacts available'))
            : ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ContactCard(contact: contact);
          },
        ),
      ),
    );
  }
}
class ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String profilePictureUrl = 'https://via.placeholder.com/150'; // Default URL
    Uint8List? imageData;

    if (contact != null && contact['profile_pics'] != null && contact['profile_pics'].isNotEmpty) {
      final profilePic = contact['profile_pics'];

      if (profilePic['image_data'] != null) {
        try {
          imageData = base64Decode(profilePic['image_data']);
          print('Successfully decoded image data.');
        } catch (e) {
          print('Error decoding image data: $e');
        }
      } else {
        print('No image data found for profile picture.');
      }
    } else {
      print('No profile pictures found in contact.');
    }

    return Card(
      color: Theme.of(context).canvasColor,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300], // Fallback background
          child: imageData != null
              ? ClipOval(
            child: Image.memory(
              imageData,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading memory image: $error');
                return Icon(Icons.person);
              },
            ),
          )
              : ClipOval(
            child: Image.network(
              profilePictureUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading network image: $error');
                return Icon(Icons.person);
              },
            ),
          ),
        ),
        title: Text(
          contact['name'] ?? 'No Name',
          style: Theme.of(context).textTheme.bodyLarge, // Use bodyLarge style for name
        ),
        subtitle: Text(
          contact['email'] ?? 'No Email',
          style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium style for email
        ),
        onTap: () => _showContactDialog(context),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    String profilePictureUrl = 'https://via.placeholder.com/150'; // Default URL
    Uint8List? imageData;

    if (contact != null && contact['profile_pics'] != null && contact['profile_pics'].isNotEmpty) {
      final profilePic = contact['profile_pics'];

      if (profilePic['image_data'] != null) {
        try {
          imageData = base64Decode(profilePic['image_data']);
          print('Successfully decoded image data.');
        } catch (e) {
          print('Error decoding image data: $e');
        }
      } else {
        print('No image data found for profile picture.');
      }
    } else {
      print('No profile pictures found in contact.');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: 300, // Adjust the width as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 50, // Increased size for better visibility
                    child: imageData != null
                        ? ClipOval(
                      child: Image.memory(
                        imageData,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(profilePictureUrl);
                        },
                      ),
                    )
                        : ClipOval(
                      child: Image.network(
                        profilePictureUrl,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 50);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name and Email
                  Text(
                    contact['name'] ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), // Using headlineSmall for name
                  ),
                  Text(
                    contact['email'] ?? 'No Email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16), // Using bodyLarge for email
                  ),
                  const SizedBox(height: 20),
                  // Additional Info (if any)
                  _buildAdditionalInfo(context),
                  const SizedBox(height: 10),
                  // Contact Info Sections
                  _buildInfoSection('Phone Numbers', contact['phone_numbers'], context),
                  _buildInfoSection('Social Links', contact['social_links'], context),
                  _buildInfoSection('Job Info', contact['job_info'], context),
                  _buildInfoSection('Custom Fields', contact['custom_fields'], context),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showQRCodeDialog(context, contact);
                  },
                  icon: Icon(Icons.qr_code),
                  label: Text('Show QR Code'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Widget _buildInfoSection(String title, List<dynamic>? items, BuildContext context) {
    if (items == null || items.isEmpty) {
      return SizedBox(); // Return an empty widget if there are no items
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), // Use bodyLarge with bold
        ),
        const SizedBox(height: 8), // Space between title and list
        ...getList(items, title, context), // Spread operator to include items
      ],
    );
  }

  List<Widget> getList(List<dynamic> items, String title, BuildContext context) {
    return items.map((item) {
      final itemTitle = _getItemTitle(title, item);
      final itemSubtitle = _getItemSubtitle(title, item);
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(
            itemTitle,
            style: Theme.of(context).textTheme.bodyLarge, // Use the bodyLarge style from the theme
          ),
          subtitle: Text(
            itemSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), // Use bodyMedium with custom color
          ),
          onTap: () {
            // Copy to clipboard
            Clipboard.setData(ClipboardData(text: itemSubtitle));
            // Show a snackbar to indicate the action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: $itemSubtitle')),
            );
          },
        ),
      );
    }).toList(); // Convert the iterable to a List<Widget>
  }

  String _getItemTitle(String category, dynamic item) {
    switch (category) {
      case 'Phone Numbers':
        return item['type'] ?? 'Unknown';
      case 'Social Links':
        return item['platform'] ?? 'Unknown';
      case 'Job Info':
        return item['title'] ?? 'Unknown';
      case 'Custom Fields':
        return item['label'] ?? 'Unknown';
      default:
        return 'Unknown';
    }
  }

  String _getItemSubtitle(String category, dynamic item) {
    switch (category) {
      case 'Phone Numbers':
        return item['number'] ?? 'No number';
      case 'Social Links':
        return item['url'] ?? 'No URL';
      case 'Job Info':
        return item['company'] ?? 'No company';
      case 'Custom Fields':
        return item['value'] ?? 'No value';
      default:
        return 'No information';
    }
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    final additionalInfo = [
      {'title': 'Address', 'value': contact['address']},
      {'title': 'Website', 'value': contact['website']},
      {'title': 'Date of Birth', 'value': contact['date_of_birth']},
      {'title': 'Notes', 'value': contact['notes']},
    ];

    if (additionalInfo == null || additionalInfo.isEmpty) {
      return SizedBox(); // Return an empty widget if there are no items
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: additionalInfo
          .where((info) => info['value'] != null && info['value'].isNotEmpty)
          .map((info) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(
            info['title']!,
            style: Theme.of(context).textTheme.headlineSmall, // Using headlineSmall
          ),
          subtitle: Text(
            info['value']!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14), // Using bodyLarge with custom font size
          ),
          onTap: () {
            // Copy to clipboard
            Clipboard.setData(ClipboardData(text: info['value']!));
            // Show a snackbar to indicate the action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: ${info['value']!}')),
            );
          },
        ),
      ))
          .toList(),
    );
  }
}

void _showQRCodeDialog(BuildContext context, Map<String, dynamic> contact) async {
  const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
  final String url = '$baseUrl/contact-profiles/${contact['id']}/qr-code';

  // Show loading dialog
  final loadingDialog = AlertDialog(
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 20),
        Text('Loading QR Code...'),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog while loading
    builder: (BuildContext context) {
      return loadingDialog;
    },
  );

  try {
    final response = await http.get(Uri.parse(url));

    // Close the loading dialog
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final Map<String, dynamic> qrCodeResponse = json.decode(response.body);
      final Uint8List imageData = base64Decode(qrCodeResponse['image_data']);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 2,
              ),
            ),
            title: Text('QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  imageData,
                  fit: BoxFit.contain,
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 100);
                  },
                ),
                SizedBox(height: 20),
                Text('Scan this QR code to share contact information'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to load QR code');
    }
  } catch (e) {
    // Close the loading dialog
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load QR code. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}