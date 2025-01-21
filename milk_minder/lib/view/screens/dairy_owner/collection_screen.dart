import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../controller/milk_collection_provider.dart';
import 'add_collection_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  bool isMorningSelected = false;
  bool isEveningSelected = false;
  bool isCowSelected = false;
  bool isBuffaloSelected = false;

  DateTime? get selectedDate =>
      context.read<MilkCollectionProvider>().selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilkCollectionProvider>().fetchMilkCollectionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          _buildFilterSection(),
          _buildCollectionsList(),
        ],
      ),
      floatingActionButton: _buildAddCollectionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF40A98D),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Collections',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Row(
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(selectedDate!)
                  : DateFormat('yyyy-MM-dd').format(DateTime.now()),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: _showDatePicker,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              'Filter Collections',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(children: _buildTimeFilters()),
            const SizedBox(height: 12),
            Row(children: _buildTypeFilters()),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsList() {
    return Consumer<MilkCollectionProvider>(
      builder: (ctx, provider, child) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.collectionList.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No collections found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new collection to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Group collections by shift (Morning/Evening)
        final groupedCollections =
            _groupCollectionsByShift(provider.collectionList);

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final shift = groupedCollections.keys.elementAt(index);
              final collections = groupedCollections[shift]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      shift,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ...collections
                      .map((collection) => _buildCollectionCard(collection)),
                ],
              );
            },
            childCount: groupedCollections.length,
          ),
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupCollectionsByShift(
      List<Map<String, dynamic>> collections) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var collection in collections) {
      final shift = collection['deliveryTime'] as String;
      if (!grouped.containsKey(shift)) {
        grouped[shift] = [];
      }
      grouped[shift]!.add(collection);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(
              collection['farmerName'] ?? 'Unknown',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${collection['liters']}L',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF40A98D),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(
                  collection['milkType'],
                  collection['milkType'] == 'Cow' ? '🐄' : '🐃',
                ),
                const Spacer(),
                Text(
                  '₹${(double.tryParse(collection['total'].toString()) ?? 0).toStringAsFixed(1)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      context.read<MilkCollectionProvider>().setSelectedDate(pickedDate);
    }
  }

  Widget _buildAddCollectionButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40A98D).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddCollectionScreen()),
          );
        },
        backgroundColor: const Color(0xFF40A98D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Collection',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Your existing filter methods remain the same
  List<Widget> _buildTimeFilters() {
    return [
      Expanded(
        child: _buildFilterChip(
          icon: '☀️',
          label: 'Morning',
          isSelected: isMorningSelected,
          onTap: () {
            setState(() {
              isMorningSelected = !isMorningSelected;
              isEveningSelected = false;
            });
            _applyFilters();
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
              isEveningSelected = !isEveningSelected;
              isMorningSelected = false;
            });
            _applyFilters();
          },
        ),
      ),
    ];
  }

  List<Widget> _buildTypeFilters() {
    return [
      Expanded(
        child: _buildFilterChip(
          icon: '🐄',
          label: 'Cow',
          isSelected: isCowSelected,
          onTap: () {
            setState(() {
              isCowSelected = !isCowSelected;
              isBuffaloSelected = false;
            });
            _applyFilters();
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
              isBuffaloSelected = !isBuffaloSelected;
              isCowSelected = false;
            });
            _applyFilters();
          },
        ),
      ),
    ];
  }

  void _applyFilters() {
    context.read<MilkCollectionProvider>().filterMilkData(
          isMorningSelected: isMorningSelected,
          isEveningSelected: isEveningSelected,
          isCowSelected: isCowSelected,
          isBuffaloSelected: isBuffaloSelected,
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

  Widget _buildChip(String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
