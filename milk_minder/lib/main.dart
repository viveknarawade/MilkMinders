import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:milk_minder/view/screens/dairy_owner/home_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/rate_screen.dart';
import 'package:milk_minder/view/screens/farmer/farmer_home_screen.dart';
import 'package:milk_minder/view/screens/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
