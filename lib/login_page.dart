import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GoogleSignIn_id.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'container.dart';

// Define _loginPageKey without const
final GlobalKey<LoginPageState> _loginPageKey = GlobalKey<LoginPageState>();

class LoginPage extends StatefulWidget {
  LoginPage({super.key})
      : _key = _loginPageKey;

  final GlobalKey<LoginPageState> _key;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();

    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      debugPrint('User changed: $account');
      setState(() {
        _user = account;
      });

      if (_user != null) {
        await _handleSignIn();
      }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAuthentication googleSignInAuthentication = await _user!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? firebaseUser = authResult.user;

      if (firebaseUser != null) {
        debugPrint("Successfully signed in: ${firebaseUser.displayName}");
        loginAndFetchData();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainContainer(), // Replace with your main page
          ),
        );
      } else {
        debugPrint("Failed to sign in");
      }
    } catch (e) {
      debugPrint("Error during sign in: $e");
    }
  }

  Future<void> logintobackend() async {
    // const String url = 'http://127.0.0.1:8000/api/login';
    const String url = 'http://127.0.0.1:8000/api/login'; // For Local Development
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final user = responseData['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('user_id', user['id']);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        await prefs.setString('profile_photo_url', user['profile_photo_url']);
        await prefs.setString('api_token', responseData['token']);
        print('Login successful: $responseData');
      } else {
        print('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> loginAndFetchData() async {
    await logintobackend();

    // Assuming you've saved the user ID during login
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      await getContactProfiles(userId);
      await getSavedContacts(userId);
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> getContactProfiles(int userId) async {
    const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
    final String url = '$baseUrl/users/$userId/contact-profiles';
    final prefs = await SharedPreferences.getInstance();
    final String? apiToken = prefs.getString('api_token');

    final headers = {
      'Authorization': 'Bearer $apiToken',
    };


    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic>? contactProfiles = json.decode(response.body) as List?;
        if (contactProfiles == null || contactProfiles.isEmpty) {
          print('No saved contacts found.');
          return;
        }

        final List<Map<String, dynamic>> simplifiedProfiles = contactProfiles.map((profile) {
          return {
            'id': profile['id'],
            'user_id': profile['user_id'],
            'name': profile['name'] ?? '',
            'email': profile['email'] ?? '',
            'address': profile['address'] ?? '',
            'website': profile['website'] ?? '',
            'date_of_birth': profile['date_of_birth'] ?? '',
            'notes': profile['notes'] ?? '',
            'created_at': profile['created_at'],
            'updated_at': profile['updated_at'],
            'profile_pics': profile['profile_picture'] ?? '',
            'phone_numbers': (profile['phone_numbers'] as List?)?.map((phone) => {
              'type': phone['type'],
              'number': phone['number'],
            }).toList() ?? [],
            'social_links': (profile['social_links'] as List?)?.map((link) => {
              'platform': link['platform'],
              'url': link['url'],
            }).toList() ?? [],
            'custom_fields': (profile['custom_fields'] as List?)?.map((field) => {
              'label': field['label'],
              'value': field['value'],
            }).toList() ?? [],
            'job_info': (profile['job_info'] as List?)?.map((job) => {
              'title': job['title'],
              'company': job['company'],
            }).toList() ?? [],
          };
        }).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('contact_profiles', json.encode(simplifiedProfiles));
        print('Contact profiles fetched and saved successfully');
      } else {
        print('Failed to fetch contact profiles: ${response.body}');
      }
    } catch (e) {
      print('Error fetching contact profiles: $e');
    }
  }

  Future<void> getSavedContacts(int userId) async {
    const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
    final String url = '$baseUrl/users/$userId/saved-contacts';
    final prefs = await SharedPreferences.getInstance();
    final String? apiToken = prefs.getString('api_token');

    final headers = {
      'Authorization': 'Bearer $apiToken',
    };


    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic>? savedContacts = json.decode(response.body) as List<dynamic>?;

        if (savedContacts == null || savedContacts.isEmpty) {
          print('No saved contacts found.');
          return;
        }

        final List<Map<String, dynamic>> simplifiedContacts = savedContacts.map((contact) {
          return {
            'id': contact['id'],
            'user_id': contact['user_id'],
            'name': contact['name'] ?? '',
            'email': contact['email'] ?? '',
            'address': contact['address'] ?? '',
            'website': contact['website'] ?? '',
            'date_of_birth': contact['date_of_birth'] ?? '',
            'notes': contact['notes'] ?? '',
            'profile_pics': contact['profile_picture'] ?? '',
            'created_at': contact['created_at'],
            'updated_at': contact['updated_at'],
            'phone_numbers': (contact['phone_numbers'] as List<dynamic>?)?.map((phone) => {
              'type': phone['type'],
              'number': phone['number'],
            }).toList() ?? [],
            'social_links': (contact['social_links'] as List<dynamic>?)?.map((link) => {
              'platform': link['platform'],
              'url': link['url'],
            }).toList() ?? [],
            'job_info': (contact['job_info'] as List<dynamic>?)?.map((job) => {
              'title': job['title'],
              'company': job['company'],
            }).toList() ?? [],
            'custom_fields': (contact['custom_fields'] as List<dynamic>?)?.map((field) => {
              'label': field['label'],
              'value': field['value'],
            }).toList() ?? [],
          };
        }).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_contacts', json.encode(simplifiedContacts));
        print('Saved contacts fetched and saved successfully');
      } else {
        print('Failed to fetch saved contacts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching saved contacts: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await googleSignIn.signIn();
    } catch (e) {
      debugPrint("Error during Google sign-in: $e");
    }
  }

  Future<void> signInWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog('Input Error', 'Email and Password cannot be empty.');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      loginAndFetchData();

      Navigator.of(context).pop(); // Close the loading indicator
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainContainer()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      showErrorDialog('Sign In Error', errorMessage);
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator
      showErrorDialog('Error', 'An unexpected error occurred: $e');
    }
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _loginPageKey,
      backgroundColor: const Color(0xFF79826A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE5D2B0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40A578),
                      border: Border.all(
                        color: const Color(0xFF252728), // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(
                          10.0), // Border radius
                    ),
                    child: Image.asset(
                      'resources/img_1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Qr_Share Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF252728),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF252728)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Color(0x000ffccc)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF252728)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Color(0x000ffccc)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      signInWithGoogle();
                    },
                    child:
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage("resources/img.png"),
                            height: 50.0,
                            width: 50.0,
                          ),
                          SizedBox(width: 8),  // Add some spacing between the image and the text
                          Flexible(
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,  // Ensure text doesn't overflow
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      signInWithEmail();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return const Color(0xFF40A578);
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(12.0),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register here.",
                      style: TextStyle(
                        color: Color(0xFF252728),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();

    // Listen for changes in the GoogleSignIn account
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      debugPrint('User changed: $account');
      setState(() {
        user = account;
      });

      if (user != null) {
        await _handleSignIn();
      }
    });

    // Attempt to sign in silently
    googleSignIn.signInSilently();
  }

  Future<void> registertobackend() async {
    const String url = 'http://127.0.0.1:8000/api/register';

    // Prepare headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    String trimEmail(String email) {
      int atIndex = email.indexOf('@');

      if (atIndex != -1) {
        return email.substring(0, atIndex);
      }

     return email;
    }

    String trimmedEmail = trimEmail(emailController.text);

    // Prepare body
    Map<String, dynamic> body = {
      'name': trimmedEmail,
      'email': emailController.text,
      'password': passwordController.text,
      'password_confirmation': passwordController.text,

    };


    // Send the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Registration successful
        final responseData = json.decode(response.body);
        print('Registration successful: $responseData');
        // Handle successful registration (e.g., navigate to login screen)
      } else {
        // Registration failed
        print('Registration failed: ${response.body}');
        // Handle errors (e.g., display error messages)
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAuthentication googleSignInAuthentication = await user!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? firebaseUser = authResult.user;

      if (firebaseUser != null) {
        debugPrint("Successfully signed in: ${firebaseUser.displayName}");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainContainer(), // Replace with your main page
          ),
        );
      } else {
        debugPrint("Failed to sign in");
      }
    } catch (e) {
      debugPrint("Error during sign in: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await googleSignIn.signIn();
    } catch (e) {
      debugPrint("Error during Google sign-in: $e");
    }
  }

  Future<void> register() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Attempt to create a new user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      registertobackend();

      Navigator.of(context).pop();

      if (userCredential.user != null) {
        // Registration successful
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainContainer(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator

      // Handle any other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred. Please try again. Error code: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF79826A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE5D2B0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40A578),
                      border: Border.all(
                        color: const Color(0xFF252728), // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10.0), // Border radius
                    ),
                    child: Image.asset(
                      'resources/img_1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Qr_Share Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF252728),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF252728)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Color(0x000ffccc)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF252728)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Color(0x000ffccc)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                    ),
                    onPressed: signInWithGoogle,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage("resources/img.png"),
                            height: 50.0,
                            width: 50.0,
                          ),
                          SizedBox(width: 8),  // Add some spacing between the image and the text
                          Flexible(
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,  // Ensure text doesn't overflow
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      register(); // Call the register function
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return const Color(0xFF40A578);
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(12.0),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to LoginPage
                    },
                    child: const Text(
                      "Already have an account? Login here.",
                      style: TextStyle(
                        color: Color(0xFF252728),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
