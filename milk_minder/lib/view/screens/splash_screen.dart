import 'package:flutter/material.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';
import 'package:milk_minder/services/farmer_session_data.dart';
import 'package:milk_minder/view/screens/auth/login_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/home_screen.dart';
import 'package:milk_minder/view/screens/farmer/farmer_home_screen.dart';
import '../widget/custom_sizedbox.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigation();
  }

  void navigation() async {
    await Future.delayed(const Duration(seconds: 3));

    await DairyOwnerSessionData.getSessionData();
    await FarmerSessionData.getSessionData();

    if (!mounted) return;

    if (FarmerSessionData.isLogin!) {
      if (DairyOwnerSessionData.role == "Farmer") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FarmerHomeScreen(),
          ),
        );
        return;
      } else if (DairyOwnerSessionData.role == "DairyOwner") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        return;
      }
    }

    // Default fallback to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.network(
                    "https://th.bing.com/th/id/OIP.GPcvhdFWzNpez-2VzZhrTgHaHa?w=198&h=198&c=7&r=0&o=5&dpr=1.3&pid=1.7",
                    width: 150,
                    height: 150,
                  ),
                ),
                CustomSizedBox.heigthSizedBox(30),
                const Text(
                  "Milk Collection App",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                CustomSizedBox.heigthSizedBox(10),
                const Text(
                  "Streamline Your Dairy Operations",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                CustomSizedBox.heigthSizedBox(40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
