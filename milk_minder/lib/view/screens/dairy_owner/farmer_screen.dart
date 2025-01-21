import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/farmer_list_provider.dart';
import 'add_farmer_screen.dart';
import 'all_farmer_report_screen.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _showFab = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getFarmerList();

    _scrollController.addListener(() {
      setState(() {
        _showFab = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;
      });
    });
  }

  getFarmerList() async {
    await context.read<FarmerListProvider>().fetchFarmersFromDairyOwner();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF40A98D),
        title: Text(
          "Farmers",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AllFarmersReport(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          Expanded(
            child: Consumer<FarmerListProvider>(
              builder: (context, farmerProvider, child) {
                final filteredFarmers =
                    _getFilteredFarmers(farmerProvider.list);
                return _buildFarmersList(filteredFarmers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search by code, mobile, or name",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFarmers(
      List<Map<String, dynamic>> farmers) {
    if (searchQuery.isEmpty) return farmers;

    return farmers.where((farmer) {
      final name = farmer["name"]?.toString().toLowerCase() ?? '';
      final code = farmer["code"]?.toString().toLowerCase() ?? '';
      final number = farmer["Number"]?.toString().toLowerCase() ?? '';

      return name.contains(searchQuery) ||
          code.contains(searchQuery) ||
          number.contains(searchQuery);
    }).toList();
  }

  Widget _buildFarmersList(List<Map<String, dynamic>> farmers) {
    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: farmers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildFarmerCard(farmers[index]),
    );
  }

  Widget _buildFarmerCard(Map<String, dynamic> farmer) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle farmer card tap
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: _buildFarmerCode(farmer["code"]),
            title: Text(
              "${farmer["name"]}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "${farmer["Number"]}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: _buildActionButton(
              Icons.phone,
              const Color(0xFF40A98D),
              () => _launchPhoneCall(farmer["Number"]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerCode(String code) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: const Color(0xFF40A98D),
        ),
        color: const Color(0xFF40A98D).withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          code,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF40A98D),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _showFab ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showFab ? 1 : 0,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF40A98D),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddFarmerScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: Text(
            'Add Farmer',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri url = Uri(
      scheme: "tel",
      path: phoneNumber,
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      log("Failed to launch the dialer: $e");
    }
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}
