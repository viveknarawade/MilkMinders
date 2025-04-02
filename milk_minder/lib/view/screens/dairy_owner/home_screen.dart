import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';

import 'package:milk_minder/view/screens/dairy_owner/analytics_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/collection_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/farmer_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/profile_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/rate_screen.dart';
import 'package:provider/provider.dart';

import '../../../controller/milk_collection_provider.dart';
import '../../widget/custom_sizedbox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      const AnalyticsScreen(),
      DairyOwnerProfilePage(),
    ];
    initial();
  }

  initial() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilkCollectionProvider>().fetchMilkCollectionData();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF40A98D),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isCowSelected = true;
  bool isBuffaloSelected = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 170,
          pinned: true,
          backgroundColor: const Color.fromRGBO(124, 180, 70, 1),
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF40A98D),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello,',
                                    style: GoogleFonts.poppins(
                                      fontSize: 19,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${DairyOwnerSessionData.ownerName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Good Morning! 🌞',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Container(
              height: 30.0,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: SizedBox(
                height: 20,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                        "Today's Collection", Icons.info_outline),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomSizedBox.widthSizedBox(10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isCowSelected = true;
                              isBuffaloSelected = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isCowSelected
                                  ? const Color(0xFF40A98D).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCowSelected
                                    ? const Color(0xFF40A98D)
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isCowSelected)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🐄',
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  "Cow",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isCowSelected
                                        ? const Color(0xFF40A98D)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CustomSizedBox.widthSizedBox(10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isBuffaloSelected = true;
                              isCowSelected = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isBuffaloSelected
                                  ? const Color(0xFF40A98D).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isBuffaloSelected
                                    ? const Color(0xFF40A98D)
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isBuffaloSelected)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("🐃",
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  "Buffalo",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isBuffaloSelected
                                        ? const Color(0xFF40A98D)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shift',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Text('Liters',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Text('Rate',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Text('Amount',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          _buildTodayCollectionListView(
                              isCowSelected, isBuffaloSelected)
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                        'Quick Actions', Icons.grid_view_rounded),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
                      child: GridView.count(
                        physics:
                            const NeverScrollableScrollPhysics(), // Add this
                        crossAxisCount: 3,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _buildMenuCard(
                            'Collection',
                            const Color(0xFF40A98D),
                            Icons.local_shipping,
                            context,
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CollectionsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuCard(
                            'Farmer',
                            const Color(0xFF40A98D),
                            Icons.people_rounded,
                            context,
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FarmerScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuCard(
                            'Rate',
                            const Color(0xFF40A98D),
                            Icons.price_change_rounded,
                            context,
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RateScreen(),
                                ),
                              );
                            },
                          ),
                          // Add other menu cards here
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTodayCollectionListView(
    bool isCowSelected, bool isBuffaloSelected) {
  return Consumer<MilkCollectionProvider>(
    builder: (context, provider, child) {
      // Check if provider is loading
      if (provider.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Filter for today's data based on selected milk types
      final todayData = provider.collectionList.where((collection) {
        // First filter by milk type
        if (isCowSelected && collection['milkType'] != 'Cow') return false;
        if (isBuffaloSelected && collection['milkType'] != 'Buffalo')
          return false;
        return true;
      }).toList();

      // Group by delivery time (Morning/Evening)
      Map<String, Map<String, double>> summarizedData = {
        'Morning': {'liters': 0.0, 'amount': 0.0},
        'Evening': {'liters': 0.0, 'amount': 0.0},
      };

      for (var collection in todayData) {
        String shift = collection['deliveryTime'] as String;
        double liters = double.tryParse(collection['liters'].toString()) ?? 0.0;
        double rate = double.tryParse(collection['rate'].toString()) ?? 0.0;

        if (summarizedData.containsKey(shift)) {
          summarizedData[shift]!['liters'] =
              (summarizedData[shift]!['liters'] ?? 0) + liters;
          summarizedData[shift]!['amount'] =
              (summarizedData[shift]!['amount'] ?? 0) + (liters * rate);
        }
      }

      if (todayData.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No collections for today'),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: summarizedData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          String shift = summarizedData.keys.elementAt(index);
          var data = summarizedData[shift]!;
          double liters = data['liters'] ?? 0;
          double amount = data['amount'] ?? 0;
          double rate = liters > 0 ? amount / liters : 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shift,
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                Text(
                  '${liters.toStringAsFixed(1)} L',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${rate.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildSectionHeader(String title, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(124, 180, 70, 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF40A98D),
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF40A98D),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMenuCard(
  String title,
  Color color,
  IconData icon,
  BuildContext context,
  VoidCallback onTap,
) {
  return Card(
    elevation: 4,
    shadowColor: color.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
