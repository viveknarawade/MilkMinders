import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:milk_minder/controller/analytics_provider.dart';
import 'package:milk_minder/controller/farmer_list_provider.dart';
import 'package:milk_minder/controller/farmer_milk_collection_provider.dart';
import 'package:milk_minder/controller/milk_collection_provider.dart';

import 'package:milk_minder/view/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAEnCw7hq3eV1QM_gq-HuDkXuU5-5AKvb8",
        appId: "1:219550559450:android:82505e1d7080a6b508c9e3",
        messagingSenderId: "219550559450",
        projectId: "milk-collection-app-d9cd6"),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FarmerListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MilkCollectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FarmerMilkCollectionProvider(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
