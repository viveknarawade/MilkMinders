import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:milk_minder/controller/farmer_list_provider.dart';
import 'package:milk_minder/services/firestore_service.dart';
import 'package:milk_minder/view/widget/custom_searchbar.dart';
import 'package:provider/provider.dart';

import '../../../controller/milk_collection_provider.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  bool isMorningSelected = false;
  bool isEveningSelected = false;
  bool isCowSelected = false;
  bool isBuffaloSelected = false;
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController literController = TextEditingController();
  final TextEditingController fatController = TextEditingController();

  String? selectedFarmerName;
  String? selectedFarmerNumber;

  DateTime? selectedDate;

  double totalRate = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<FarmerListProvider>().fetchFarmersFromDairyOwner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF40A98D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Collection',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateTimeSection(),
                    const SizedBox(height: 16),
                    _buildSearchSection(),
                    const SizedBox(height: 16),
                    if (selectedFarmerName != null) _buildSelectedFarmer(),
                    const SizedBox(height: 16),
                    _buildMilkTypeSection(),
                    const SizedBox(height: 16),
                    _buildMeasurementSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

// date time
  Widget _buildDateTimeSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                // Show date picker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'Select Date'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    icon: '☀️',
                    label: 'Morning',
                    isSelected: isMorningSelected,
                    onTap: () {
                      setState(() {
                        isMorningSelected = true;
                        isEveningSelected = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    icon: '🌙',
                    label: 'Evening',
                    isSelected: isEveningSelected,
                    onTap: () {
                      setState(() {
                        isEveningSelected = true;
                        isMorningSelected = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// search bar
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSearchbar.showCustomSearchbar(
          "Search farmer",
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              isSearching = query.isNotEmpty;
              context.read<FarmerListProvider>().filterFarmers(query);
            });
          },
        ),
        if (isSearching)
          Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Consumer<FarmerListProvider>(
              builder: (context, farmerList, child) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: farmerList.list.length,
                    itemBuilder: (context, index) {
                      final farmer = farmerList.list[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedFarmerName = farmer["name"];
                            selectedFarmerNumber = farmer["Number"];
                            isSearching = false;
                            _searchController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF40A98D).withOpacity(0.1),
                                child: Text(
                                  farmer["name"][0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF40A98D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      farmer["name"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${farmer["Number"]}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Measurement Section
  _buildMeasurementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Measurements',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Liters',
                  controller: literController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Fat %',
                  controller: fatController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF40A98D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF40A98D),
                  ),
                ),
                Text(
                  '₹${totalRate.toStringAsFixed(2).toString()}/L',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF40A98D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Milk Type Section
  _buildMilkTypeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milk Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  icon: '🐄',
                  label: 'Cow',
                  isSelected: isCowSelected,
                  onTap: () {
                    setState(() {
                      isCowSelected = true;
                      isBuffaloSelected = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  icon: '🐃',
                  label: 'Buffalo',
                  isSelected: isBuffaloSelected,
                  onTap: () {
                    setState(() {
                      isBuffaloSelected = true;
                      isCowSelected = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFarmer() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF40A98D).withOpacity(0.1),
              child: Text(
                selectedFarmerName![0].toUpperCase(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF40A98D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFarmerName!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${selectedFarmerNumber}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedFarmerName = null;
                  selectedFarmerNumber = null;
                });
              },
              icon: Icon(Icons.close, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

// calculate rate
  double _calculateRate(double liters, double fatPercentage) {
    // Define the base rate per liter
    double baseRate = 45.00;

    // Define the fat percentage multiplier (e.g., for every 1% above 3%, increase the rate by 2%)
    double fatMultiplier = 1 + (fatPercentage - 3) * 0.02;

    // Calculate the total rate
    totalRate = baseRate * liters * fatMultiplier;

    return totalRate;
  }

// liter and fat textfield
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (val) {
            setState(() {
              if (literController.text.trim().isNotEmpty &&
                  fatController.text.trim().isNotEmpty) {
                _calculateRate(double.parse(literController.text),
                    double.parse(fatController.text));
              }
            });
          },
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF40A98D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF40A98D).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF40A98D) : Colors.grey[300]!,
            width: 1.5,
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
      ),
    );
  }

// to format
  String formatDate(DateTime date) {
    return DateFormat('EEEE-dd-MMMM-yyyy').format(date);
  }

  void saveMilkCollection() async {
    try {
      String timeStamp = formatDate(selectedDate!);
      log("time stamp ${timeStamp}");

      Map<String, dynamic> data = {
        "timeStamp": timeStamp,
        "deliveryTime": (isEveningSelected) ? "Evening" : "Morning",
        "farmerName": selectedFarmerName,
        "number": selectedFarmerNumber,
        "liters": literController.text.trim(),
        "fat": fatController.text.trim(),
        "total": totalRate.toStringAsFixed(2),
        'rate': "50",
        'milkType': (isCowSelected) ? "Cow" : "Buffalo",
      };

      await FirestoreService().addMilkCollectedData(data);
      context.read<MilkCollectionProvider>().fetchMilkCollectionData();
      reset();
      setState(() {});

      // Show success SnackBar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Milk collection data added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error SnackBar if data addition fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add milk collection data: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void reset() {
    isMorningSelected = false;
    isEveningSelected = false;
    isCowSelected = false;
    isBuffaloSelected = false;
    literController.clear();
    fatController.clear();
    totalRate = 0;
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  reset();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle save
                saveMilkCollection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40A98D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
