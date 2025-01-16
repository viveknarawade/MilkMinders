import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/view/widget/custom_searchbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF40A98D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Collections',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '09/01/2025',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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

          //Search bar
          Padding(
            padding: EdgeInsets.all(20),
            child: CustomSearchbar.showCustomSearchbar("Search"),
          ),
          const SizedBox(height: 20),
         
         // cow and buffalo button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Milk type"),
              const SizedBox(width: 10),
              _buildFilterChip(
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
              const SizedBox(width: 10),
              _buildFilterChip(
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
            ],
          ),
          const Divider(height: 1),
        
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text("Liter"),
              Divider(height: 1),
              Text("Rate"),
            ],
          ),
          const Spacer(),
          _buildBottomButtons(),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF40A98D).withOpacity(0.1)
              : Colors.white,
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
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'RESET',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 56,
              color: const Color(0xFF40A98D),
              child: TextButton(
                onPressed: () {
                  // Handle save
                },
                child: Text(
                  'SAVE',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
