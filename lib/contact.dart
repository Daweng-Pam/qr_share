import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'Services/LoginPageService.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io';

class PersonalProfiles extends StatefulWidget {
  const PersonalProfiles({Key? key}) : super(key: key);

  @override
  _PersonalProfilesState createState() => _PersonalProfilesState();
}

class _PersonalProfilesState extends State<PersonalProfiles> {
  List<Map<String, dynamic>> profiles = [];
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUserId();
    await _loadProfiles();
    setState(() => isLoading = false);
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
  }

  Future<void> _refreshProfiles() async {
    setState(() => isLoading = true);
    if (userId != null) {
      await LoginPageService().getContactProfiles(userId!);
      await _loadProfiles();
    } else {
      print('User ID is not available');
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('contact_profiles');

    if (profilesJson != null) {
      final decodedProfiles = json.decode(profilesJson);
      if (decodedProfiles is List) {
        setState(() {
          profiles = List<Map<String, dynamic>>.from(decodedProfiles);
        });
      }
    }
  }

  void _addProfile() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddProfilePage()),
    );
    if (result == true) {
      _refreshProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profiles.isEmpty
          ? const Center(child: Text('No profiles available'))
          : ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ProfileCard(profile: profiles[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProfile,
        tooltip: 'Add Profile',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileCard({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String profilePictureUrl = 'https://via.placeholder.com/150'; // Default URL
    Uint8List? imageData;

    if (profile != null && profile['profile_pics'] != null && profile['profile_pics'].isNotEmpty) {
      final profilePic = profile['profile_pics'];

      // Log the profile picture data

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

        title: Text(profile['name'] ?? 'No Name',
          style: Theme.of(context).textTheme.bodyLarge, // Use bodyLarge style for name
        ),
        subtitle: Text(profile['email'] ?? 'No Email',
          style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium style for email
        ),
        onTap: () => _showProfileDialog(context),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    String profilePictureUrl = 'https://via.placeholder.com/150'; // Default URL
    Uint8List? imageData;

    if (profile != null && profile['profile_pics'] != null && profile['profile_pics'].isNotEmpty) {
      final profilePic = profile['profile_pics'];
      print('Error decoding image data: $profile');


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
            width: 300, // You can adjust the width as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures the dialog doesn't take more space than needed
                children: [
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
                  const SizedBox(height: 10),
                  Text(
                    profile['name'] ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), // Using headlineSmall for name
                  ),
                  Text(profile['email'] ?? 'No Email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16), // Using bodyLarge for email
                  ),
                  const SizedBox(height: 10),
                  _buildAdditionalInfo(context),
                  const SizedBox(height: 10),
                  _buildInfoList('Phone Numbers', profile['phone_numbers'], context),
                  _buildInfoList('Social Links', profile['social_links'], context),
                  _buildInfoList('Job Info', profile['job_info'], context),
                  _buildInfoList('Custom Fields', profile['custom_fields'], context),
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
                    _showQRCodeDialog(context, profile);
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


  Widget _buildInfoList(String title, List<dynamic>? items, BuildContext context) {
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
      {'title': 'Address', 'value': profile['address']},
      {'title': 'Website', 'value': profile['website']},
      {'title': 'Date of Birth', 'value': profile['date_of_birth']},
      {'title': 'Notes', 'value': profile['notes']},
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

void _showQRCodeDialog(BuildContext context, Map<String, dynamic> profile) async {
  const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
  final String url = '$baseUrl/contact-profiles/${profile['id']}/qr-code';

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

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({Key? key}) : super(key: key);

  @override
  _AddProfilePageState createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _profile = <String, dynamic>{};
  final _phoneNumbers = <Map<String, String>>[];
  final _jobs = <Map<String, String>>[];
  final _socialLinks = <Map<String, String>>[];
  final _customFields = <Map<String, String>>[];
  Uint8List? _imageBytes;
  final picker = ImagePicker();

  // Add controllers for each text field
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    } else {
      print('No image selected.');
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _profile['name'] = _nameController.text;
      _profile['email'] = _emailController.text;
      _profile['address'] = _addressController.text;
      _profile['birthday'] = _birthdayController.text;
      _profile['website'] = _websiteController.text;
      _profile['phone_numbers'] = _phoneNumbers;
      _profile['job_info'] = _jobs;
      _profile['social_links'] = _socialLinks;
      _profile['custom_fields'] = _customFields;

      if (_imageBytes != null) {
        String base64Image = base64Encode(_imageBytes!);
        _profile['image'] = base64Image;
      }

      final profileData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'birthday': _birthdayController.text,
        'website': _websiteController.text,
        'phone_numbers': _phoneNumbers,
        'job_info': _jobs,
        'social_links': _socialLinks,
        'custom_fields': _customFields,
      };

      if (_imageBytes != null) {
        String base64Image = base64Encode(_imageBytes!);
        profileData['image'] = base64Image;
      }

      // Replace with your actual API base URL and user ID
      final String apiUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api';
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 0;
      final String? apiToken = prefs.getString('api_token');

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/users/$userId/contact-profiles'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $apiToken',
          },
          body: jsonEncode(profileData),
        );

        if (response.statusCode == 201) {
          // Successfully created
          print('Profile created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          // Handle error
          print('Failed to create profile. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile. Please try again.')),
          );
        }
      } catch (e) {
        // Handle any exceptions
        print('Error occurred while saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }

    }
  }

  void _addItem(String type) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(type: type, onAdd: (item) {
        setState(() {
          switch (type) {
            case 'Phone Number':
              _phoneNumbers.add(item);
              break;
            case 'Job':
              _jobs.add(item);
              break;
            case 'Social Link':
              _socialLinks.add(item);
              break;
            case 'Custom Field':
              _customFields.add(item);
              break;
          }
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: _birthdayController,
              decoration: const InputDecoration(labelText: 'Birthday'),
            ),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(labelText: 'Website'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Pick Image'),
            ),
            if (_imageBytes != null)
                Image.memory(
                  _imageBytes!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
            const SizedBox(height: 16),
            _buildDynamicList('Phone Numbers', _phoneNumbers, () => _addItem('Phone Number')),
            _buildDynamicList('Jobs', _jobs, () => _addItem('Job')),
            _buildDynamicList('Social Links', _socialLinks, () => _addItem('Social Link')),
            _buildDynamicList('Custom Fields', _customFields, () => _addItem('Custom Field')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicList(String title, List<Map<String, String>> items, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ],
        ),
        ...items.map((item) => ListTile(
          title: Text(item.values.first),
          subtitle: Text(item.values.last),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => items.remove(item)),
          ),
        )),
        const Divider(),
      ],
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final String type;
  final Function(Map<String, String>) onAdd;

  const _AddItemDialog({Key? key, required this.type, required this.onAdd}) : super(key: key);

  @override
  __AddItemDialogState createState() => __AddItemDialogState();
}

class __AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _item = <String, String>{};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.type}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: _getFirstFieldLabel()),
              validator: (value) => value!.isEmpty ? 'This field is required' : null,
              onSaved: (value) => _item[_getFirstFieldKey()] = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: _getSecondFieldLabel()),
              validator: (value) => value!.isEmpty ? 'This field is required' : null,
              onSaved: (value) => _item[_getSecondFieldKey()] = value!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onAdd(_item);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getFirstFieldLabel() {
    switch (widget.type) {
      case 'Phone Number':
        return 'Type';
      case 'Job':
        return 'Title';
      case 'Social Link':
        return 'Platform';
      case 'Custom Field':
        return 'Label';
      default:
        return 'Field 1';
    }
  }

  String _getSecondFieldLabel() {
    switch (widget.type) {
      case 'Phone Number':
        return 'Number';
      case 'Job':
        return 'Company';
      case 'Social Link':
        return 'URL';
      case 'Custom Field':
        return 'Value';
      default:
        return 'Field 2';
    }
  }

  String _getFirstFieldKey() {
    switch (widget.type) {
      case 'Phone Number':
        return 'type';
      case 'Job':
        return 'title';
      case 'Social Link':
        return 'platform';
      case 'Custom Field':
        return 'label';
      default:
        return 'key1';
    }
  }

  String _getSecondFieldKey() {
    switch (widget.type) {
      case 'Phone Number':
        return 'number';
      case 'Job':
        return 'company';
      case 'Social Link':
        return 'url';
      case 'Custom Field':
        return 'value';
      default:
        return 'key2';
    }
  }
}