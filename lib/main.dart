import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'custom ui stuff/header.dart';
import 'custom ui stuff/theme.dart';
import 'container.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase Initialized Successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Proceed to run the app even if Firebase initialization fails
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<PageTitle>(
          create: (_) => PageTitle(),
        ),
        ChangeNotifierProvider(create: (_) => ConnectivityStatus()),
        ChangeNotifierProvider(create: (context) => BatteryStatus()),

      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Qr_Share',
          theme: themeNotifier.isDarkMode ? darkTheme : lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: FutureBuilder<bool>(
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.data == true) {
                  return const MainContainer(); // If logged in, go to MainContainer
                } else {
                  return LoginPage(); // If not logged in, go to LoginPage
                }
              }
            },
          ),
        );
      },
    );
  }
}
