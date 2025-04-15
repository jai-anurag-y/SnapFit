import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'snap_photo_screen.dart';
import 'select_diet_plan_screen.dart';
import 'track_nutrition_screen.dart';
import 'track_fitness_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_diet_plan_screen.dart'; // Add this import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Add this
  
  // Set up global error widget handler
  ErrorWidget.builder = (FlutterErrorDetails details) {
    print("[DEBUG] Widget Error: ${details.exception}");
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            Text('Error: ${details.exception}'),
          ],
        ),
      ),
    );
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          headlineLarge: GoogleFonts.raleway(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      home: AuthenticationWrapper(),
    );
  }
}

// This widget checks authentication state and redirects accordingly
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're logged in
        if (snapshot.hasData) {
          return const MainScreen();
        }
        // Otherwise, they're not logged in
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();  // Remove underscore
}

class MainScreenState extends State<MainScreen> {  // Remove underscore
  int _selectedIndex = 0;
  
  // Add GlobalKeys
  final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<TrackNutritionScreenState> trackNutritionKey = GlobalKey<TrackNutritionScreenState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Force reload data when tab is selected
    if (index == 0) { // Home
      homeKey.currentState?.loadData();
    } else if (index == 3) { // Track Nutrition (changed from 2 to 3)
      trackNutritionKey.currentState?.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(key: homeKey),         // index 0: Home
          const SelectDietPlanScreen(),     // index 1: Select Diet Plan
          const SnapPhotoScreen(),          // index 2: Take Photo
          TrackNutritionScreen(key: trackNutritionKey),  // index 3: Track Nutrition
          const TrackFitnessScreen(),       // index 4: Track Fitness
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Diet Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Take Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
