import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:milk_minder/view/screens/dairy_owner/home_screen.dart';
import 'package:milk_minder/view/screens/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// ElevatedButton(
//             onPressed: () async {
//               final Uri url = Uri(
//                 scheme: "tel",
//                 path: phoneController.text,
//               );

//               try {
//                 await launchUrl(url, mode: LaunchMode.externalApplication);
//               } catch (e) {
//                 log("Failed to launch the dialer: $e");
//               }
//             },
//             child: Text("Call"),
//           ),

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
