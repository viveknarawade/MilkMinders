import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/view/screens/dairy_owner/add_farmer_screen.dart';
import 'package:milk_minder/view/screens/dairy_owner/all_farmer_report_screen.dart';
import 'package:milk_minder/view/widget/custom_searchbar.dart';
import 'package:milk_minder/view/widget/custom_sizedbox.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF40A98D),
        title: Text(
          "Farmer",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddFarmerScreen();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AllFarmersReport();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip("Active: 2", Colors.green),
                _buildStatusChip("Inactive: 2", Colors.grey),
                _buildStatusChip("Total: 2/200", const Color(0xFF6B4CE6)),
              ],
            ),
          ),
          // const Divider(height: 1),
          CustomSizedBox.heigthSizedBox(10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CustomSearchbar.showCustomSearchbar("Type code,mobile,name"),
          ),

          CustomSizedBox.heigthSizedBox(10),
          // const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: 19,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildFarmerCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFarmerCard() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: const Color(0xFF40A98D),
          ),
        ),
        child: Center(
          child: Text(
            "1",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      title: Text(
        "Farmer 1",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "mobile no",
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF6B4CE6).withOpacity(0.1),
        ),
        child: const Icon(
          Icons.phone,
          color: Color(0xFF6B4CE6),
          size: 20,
        ),
      ),
    );
  }
}
