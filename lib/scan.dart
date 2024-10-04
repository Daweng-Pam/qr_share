import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Services/LoginPageService.dart';


import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_tools/qr_code_tools.dart';


class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  bool isLoading = false;
  bool isClose = false; // State to check proximity

  void _checkProximity() {
    setState(() {
      isClose = !isClose; // Toggle for demonstration
    });
  }

  // Camera view size and position
  double cameraViewWidth = 250;
  double cameraViewHeight = 250;
  double cameraViewTop = 0;
  double cameraViewLeft = -70;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      // Permission already granted
      return;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog();
      return;
    }

    if (status.isRestricted || status.isLimited) {
      _showPermissionRestrictedDialog();
      return;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text('Please grant camera permission to use the QR scanner.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestCameraPermission();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionRestrictedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Restricted'),
          content: const Text('Camera access is currently restricted. Please check your device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text('Please enable camera permissions in app settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Add these methods to your _ScanState class
  double _getContainerWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 400 : screenWidth * 0.9;
  }

  EdgeInsets _getContainerPadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600
        ? const EdgeInsets.all(40.0)
        : const EdgeInsets.all(20.0);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: _getContainerWidth(context)),
            margin: const EdgeInsets.all(20.0),
            padding: _getContainerPadding(context),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Proximity Scanner Icon
                Icon(
                  Icons.near_me, // Use an appropriate icon
                  size: MediaQuery.of(context).size.width > 600 ? 50 : 35,
                  color: isClose ?  Theme.of(context).primaryColor : Colors.grey, // Change color based on proximity
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _checkProximity, // Toggle proximity state for demo
                  child: Text(
                    isClose ? 'Too Close' : 'Good Distance',
                    style: TextStyle(
                      color: isClose ? Theme.of(context).primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Add spacing for clarity
                Icon(
                  Icons.qr_code_scanner,
                  size: MediaQuery.of(context).size.width > 600 ? 80 : 60,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: MediaQuery.of(context).size.width > 600 ? 40 : 20),
                Text(
                  'QR Scanner',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startScanning,
                  style: _buttonStyle(),
                  child: const Text('Start Scanning', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadQRCode,
                  style: _buttonStyle(),
                  child: const Text('Upload QR Code', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  void _startScanning() {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            children: [
              Container(
                width: 300,
                height: 400,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              Positioned(
                top: cameraViewTop,
                left: cameraViewLeft,
                child: Container(
                  width: cameraViewWidth,
                  height: cameraViewHeight,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close Scanner'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        isLoading = false;
      });
      controller?.pauseCamera();
    });
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          scannedData = scanData.code;
        });
        Navigator.of(context).pop(); // Close the dialog after scanning
        controller.dispose();

        // Parse scanned data into a map and show in popup
        final parsedData = _parseQRCode(scannedData!);
        showQRDataPopup(parsedData);
      }
    });
  }



  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadQRCode() async {
    setState(() {
      isLoading = true;
    });
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      await input.onChange.first;

      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        await reader.onLoad.first;

        final Uint8List imageData = reader.result as Uint8List;

        String? qrData = await decodeQRCodeFromImageData(imageData);
        if (qrData != null) {
          print('Scanned Data: $qrData');
          final parsedData = _parseQRCode(qrData);
          showQRDataPopup(parsedData);
        } else {
          _showErrorSnackBar('No QR code found in the image');
        }
      } else {
        _showErrorSnackBar('No image selected');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> decodeQRCodeFromImageData(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final pixelData = Int32List(image.width * image.height);
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          var pixel = image.getPixel(x, y);
          final intColor = ui.Color.fromRGBO(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), pixel.a.toDouble()).value;
          pixelData[y * image.width + x] = intColor;       }
      }

      LuminanceSource source = RGBLuminanceSource(image.width, image.height, pixelData);
      var bitmap = BinaryBitmap(HybridBinarizer(source));

      var reader = QRCodeReader();
      var result = reader.decode(bitmap);

      return result?.text;
    } catch (e) {
      print('Error in QR code decoding process: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseQRCode(String data) {
    final Map<String, dynamic> result = {};
    final lines = data.split('\n');
    String currentKey = '';

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('BEGIN:') || line.startsWith('END:') ||
          line.startsWith('VERSION:') ||
          line.startsWith('PHOTO;')) {
        continue;
      }

      if (line.contains(':')) {
        final parts = line.split(':');
        currentKey = parts[0].split(';')[0].trim();
        String value = parts.sublist(1).join(':').trim();

        // Handle special cases
        switch (currentKey) {
          case 'BDAY':
            try {
              final date = DateTime.parse(value);
              value = DateFormat('MMMM d, y').format(date);
            } catch (e) {
              // If parsing fails, keep the original value
            }
            break;
          case 'ADR':
            value = value.replaceAll(',', ', ');
            break;
          case 'TEL':
          case 'URL':
            String type = parts[0].contains('TYPE=') ? parts[0].split('TYPE=')[1] : 'OTHER';
            if (!result.containsKey(currentKey)) {
              result[currentKey] = <String, String>{};
            }
            (result[currentKey] as Map<String, String>)[type] = value;
            continue;
          case 'TITLE':
          case 'ORG':
            if (!result.containsKey(currentKey)) {
              result[currentKey] = [];
            }
            (result[currentKey] as List).add(value);
            continue;
        }

        if (result.containsKey(currentKey)) {
          if (result[currentKey] is! List) {
            result[currentKey] = [result[currentKey]];
          }
          (result[currentKey] as List).add(value);
        } else {
          result[currentKey] = value;
        }
      } else if (currentKey.isNotEmpty) {
        // Append to the previous value for multi-line entries
        if (result[currentKey] is List) {
          (result[currentKey] as List).last += '\n$line';
        } else if (result[currentKey] is String) {
          result[currentKey] = '${result[currentKey]}\n$line';
        }
      }
    }

    // Ensure all entries are of type String
    final StringMap = result.map((key, value) {
      if (value is Map) {
        return MapEntry(key, value.map((k, v) => MapEntry(k.toString(), v.toString())));
      }
      if (value is List) {
        return MapEntry(key, value.map((v) => v.toString()).toList());
      }
      return MapEntry(key, value.toString());
    });

    return StringMap;
  }

  void showQRDataPopup(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 400, // Set the desired width here
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoTile('Name', data['FN'] ?? 'N/A', icon: Icons.person),
                  _buildInfoTile('Email', data['EMAIL'] ?? 'N/A', isEmail: true, icon: Icons.email),

                  if (data['TEL'] is Map)
                    ...data['TEL'].entries.map((entry) {
                      return _buildInfoTile('Phone (${StringUtils.capitalize(entry.key)})', entry.value.toString(), icon: Icons.phone);
                    }),

                  if (data['ORG'] is List && data['ORG'].isNotEmpty)
                    ..._buildOrgAndTitleTiles(data['ORG'], data['TITLE']),

                  _buildInfoTile('Address', data['ADR'] ?? 'N/A', icon: Icons.location_on),
                  _buildInfoTile('Birthday', data['BDAY'] ?? 'N/A', icon: Icons.cake),

                  if (data['URL'] is Map)
                    ...data['URL'].entries.map((entry) {
                      return _buildInfoTile(StringUtils.capitalize(entry.key), entry.value.toString(), isUrl: true, icon: Icons.link);
                    }),

                  _buildInfoTile('Note', data['NOTE'] ?? 'N/A', icon: Icons.note),

                  ...data.entries.where((entry) => !['FN', 'EMAIL', 'TEL', 'TITLE', 'ORG', 'ADR', 'BDAY', 'URL', 'NOTE'].contains(entry.key))
                      .map((entry) => _buildInfoTile(entry.key, entry.value.toString())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveContactInfo(data);
                Navigator.of(context).pop();
              },
              child: const Text('Save Contact'),
            ),
          ],
        );
      },
    );
  }



  List<Widget> _buildOrgAndTitleTiles(List orgs, List? titles) {
    final maxLength = (titles?.length ?? 0).clamp(0, orgs.length);
    return List<Widget>.generate(maxLength, (i) {
      String org = orgs[i].toString();
      String title = (i < (titles?.length ?? 0)) ? titles![i].toString() : 'N/A';
      return Column(
        children: [
          _buildInfoTile('ORG ${i + 1}', org, icon: Icons.business),
          _buildInfoTile('TITLE ${i + 1}', title, icon: Icons.title),
        ],
      );
    });
  }

  Widget _buildInfoTile(String title, String value, {bool isUrl = false, bool isEmail = false, IconData? icon}) {
    return GestureDetector(
      onTap: () {
        if (isUrl || isEmail) {
          _launchURL(value, isEmail: isEmail);
        } else {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title copied to clipboard')),
          );
        }
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(value, style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url, {bool isEmail = false}) async {
    if (isEmail) {
      url = 'mailto:$url';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> addContactProfile(Map<String, dynamic> data) async {
    // Retrieve user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      print('User ID not found in shared preferences.');
      return;
    }

    // Get contactProfileId from the provided data
    final String contactProfileId = data['contactProfileId'];

    const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
    final String url = '$baseUrl/users/$userId/contact-profiles/add/$contactProfileId';
    final String? apiToken = prefs.getString('api_token');

    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    };


    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        print('Contact profile added successfully.');
      } else {
        print('Failed to add contact profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding contact profile: $e');
    }
  }


  Future<void> _saveContactInfo(Map<String, dynamic> data) async {
    print('Saving contact info: $data');

    // Ensure the 'Qr_Share ID' is correctly accessed
    final contactProfileId = data['Qr_Share ID'];

    if (contactProfileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact Profile ID is missing')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 0;
      await addContactProfile({'contactProfileId': contactProfileId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact info saved')),
      );
      await LoginPageService().getSavedContacts(userId);
    } catch (e) {
      print('Error saving contact info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contact info')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}