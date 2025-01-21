import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/services/farmer_session_data.dart';
import 'package:milk_minder/services/firestore_service.dart';
import 'package:milk_minder/view/screens/farmer/milk_collection_screen.dart';
import 'package:milk_minder/view/screens/farmer/profile_screen.dart';
import 'package:milk_minder/view/screens/farmer/settings_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  Map<String, dynamic> rateMap = {};

  @override
  void initState() {
    super.initState();
    getRateList();
  }

  getRateList() async {
    rateMap = await FirestoreService().getRate();
    log(rateMap.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding =
        screenSize.width * 0.04; // 4% of screen width
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          // Changed this line to return a Future<void> function
          await getRateList();
        },
        child: CustomScrollView(
          slivers: [
            // Responsive App Bar
            SliverAppBar(
              expandedHeight: screenSize.height * 0.20, // 25% of screen height
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1E88E5),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    bottom: screenSize.height * 0.06,
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width:
                                screenSize.width * 0.2, // 20% of screen width
                            height: screenSize.width * 0.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                image:
                                    NetworkImage(FarmerSessionData.profilePic!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${FarmerSessionData.Name}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Dairy Farmer',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: Container(
                  height: 20.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            // Rates Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenSize.height * 0.02,
                ),
                child: _buildRatesSection(screenSize, isSmallScreen),
              ),
            ),

            // Dashboard Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenSize.height * 0.02,
                  crossAxisSpacing: screenSize.width * 0.04,
                  childAspectRatio: isSmallScreen ? 1.0 : 1.2,
                ),
                delegate:
                    SliverChildListDelegate(_buildDashboardItems(context)),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.03),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      onPressed: () {
        // Add profile edit functionality
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildRatesSection(Size screenSize, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatesHeader(isSmallScreen),
          SizedBox(height: screenSize.height * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildRateCard(
                  'Cow Milk',
                  '₹${(rateMap["Cow"].toString() == "null") ? 0 : rateMap["Cow"].toString()}/L',
                  Colors.blue,
                  Icons.water_drop,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: screenSize.width * 0.04),
              Expanded(
                child: _buildRateCard(
                  'Buffalo Milk',
                  '₹${(rateMap["Buffalo"].toString() == "null") ? 0 : rateMap["Buffalo"].toString()}/L',
                  Colors.purple,
                  Icons.water_drop,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatesHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today's Rates",
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Updated 2h ago',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateCard(
    String title,
    String rate,
    Color color,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rate,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Current Rate',
            style: GoogleFonts.poppins(
              color: color.withOpacity(0.7),
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDashboardItems(BuildContext context) {
    final dashboardItems = [
      {
        'title': 'Milk Collection',
        'icon': Icons.local_shipping,
        'color': const Color(0xFF4CAF50),
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MilkCollectionScreen()),
            ),
      },
      {
        'title': 'My Profile',
        'icon': Icons.person,
        'color': const Color(0xFF2196F3),
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
      },
    ];

    return dashboardItems
        .map((item) => _buildDashboardCard(
              item['title'] as String,
              item['icon'] as IconData,
              item['color'] as Color,
              item['onTap'] as VoidCallback,
            ))
        .toList();
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 24 : 32,
                  color: color,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
