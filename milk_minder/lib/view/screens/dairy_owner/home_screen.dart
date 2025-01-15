import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/view/screens/dairy_owner/collection_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/farmer_screen.dart';
import 'package:milk_minder/view/widget/custom_rate_bottomsheet.dart';

import '../../widget/custom_sizedbox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CircleAvatar(
          radius: 25,
          backgroundColor: Color.fromRGBO(124, 180, 70, 1),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, \nvivek",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Good Morning!",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(194, 195, 204, 1),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text("Today's Collection"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSizedBox.widthSizedBox(10),
                _buildFilterChip(
                  icon: '🐄',
                  label: 'Cow',
                  isSelected: false,
                ),
                CustomSizedBox.widthSizedBox(10),
                _buildFilterChip(
                  icon: '🐃',
                  label: 'Buffalo',
                  isSelected: false,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              height: 1,
            ),
            _buildTodayCollectionListView(),
            Divider(
              height: 1,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuCard(
                    'Collection',
                    Color.fromRGBO(124, 180, 70, 1),
                    Icons.local_shipping,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return CollectionsScreen();
                          },
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    'Farmer',
                    Color(0xFF6B4CE6),
                    Icons.people,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return FarmerScreen();
                          },
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    'Rate Chart',
                    Color(0xFF6B4CE6),
                    Icons.grid_on,
                    () {
                      CustomRateBottomSheet().showRateBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: _selectedIndex,
        // onTap: _onItemTapped,
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

Widget _buildTodayCollectionListView() {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: 2, // Replace with your dynamic list length
    itemBuilder: (context, index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("morning"),
          Text("88.0"),
          Text("50"),
          Text("44230"),
        ],
      );
    },
  );
}

Widget _buildFilterChip({
  required String icon,
  required String label,
  required bool isSelected,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color:
          isSelected ? const Color(0xFF40A98D).withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isSelected ? const Color(0xFF40A98D) : Colors.grey[300]!,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF40A98D) : Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

_buildMenuCard(String title, Color color, IconData icon, VoidCallback onTap) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
