import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/controller/farmer_list_provider.dart';
import 'package:milk_minder/services/firestore_service.dart';
import 'package:provider/provider.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  String? selectedMilkType;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Basic Information'),
                        _buildCard([
                          _buildTextField(
                            'Farmer Code',
                            _codeController,
                            prefixIcon: Icons.tag,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter farmer code';
                              }
                              return null;
                            },
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Personal Details'),
                        _buildCard([
                          _buildTextField(
                            'First Name',
                            _fnameController,
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter first name';
                              }
                              return null;
                            },
                          ),
                          const Divider(height: 1),
                          _buildTextField(
                            'Last Name',
                            _lnameController,
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter last name';
                              }
                              return null;
                            },
                          ),
                          const Divider(height: 1),
                          _buildTextField(
                            'Mobile Number',
                            _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter mobile number';
                              }
                              if (value!.length != 10) {
                                return 'Please enter valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Milk Details'),
                        _buildCard([
                          _buildDropdownField(),
                        ]),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF40A98D),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Add Farmer',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF40A98D))
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: 'Milk Type',
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon:
              const Icon(Icons.water_drop_outlined, color: Color(0xFF40A98D)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: Text(
          'Select milk type',
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        value: selectedMilkType,
        validator: (value) {
          if (value == null) {
            return 'Please select milk type';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            selectedMilkType = newValue;
          });
        },
        items: ['Cow', 'Buffalo', 'Both']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: GoogleFonts.poppins()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40A98D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      addFarmer();
    }
  }

  Future<void> addFarmer() async {
    try {
      List<Map<String, dynamic>> farmerListFromFarmer =
          await FirestoreService().getFarmerListFromFarmer();
      List<Map<String, dynamic>> farmerListFromOwner =
          context.read<FarmerListProvider>().list;

      String phoneNumber = _phoneController.text.trim();

      var validFarmer = farmerListFromFarmer.firstWhere(
        (farmer) => farmer["number"] == phoneNumber,
        orElse: () => {},
      );

      bool isAlreadyAddedToOwner =
          farmerListFromOwner.any((farmer) => farmer["Number"] == phoneNumber);

      if (validFarmer.isNotEmpty && !isAlreadyAddedToOwner) {
        Map<String, dynamic> farmerData = {
          "code": _codeController.text.trim(),
          "id": validFarmer['id'],
          "name":
              "${_fnameController.text.trim()} ${_lnameController.text.trim()}",
          "Number": phoneNumber,
          "milkType": selectedMilkType,
        };

        await FirestoreService().addFarmerToDairyOwner(farmerData);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Farmer added successfully!")),
          );
        }
      } else if (isAlreadyAddedToOwner) {
        _showError("Farmer already added!");
      } else {
        _showError("Farmer does not exist!");
      }
    } catch (e) {
      log("Error adding farmer: $e");
      _showError("Failed to add farmer. Please try again!");
    }

    if (mounted) {
      context.read<FarmerListProvider>().fetchFarmersFromDairyOwner();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
