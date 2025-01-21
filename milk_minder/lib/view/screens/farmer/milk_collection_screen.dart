import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controller/farmer_milk_collection_provider.dart';

class MilkCollectionScreen extends StatefulWidget {
  const MilkCollectionScreen({super.key});

  @override
  State<MilkCollectionScreen> createState() => _MilkCollectionScreenState();
}

class _MilkCollectionScreenState extends State<MilkCollectionScreen> {
  List<Map<String, dynamic>> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      await context
          .read<FarmerMilkCollectionProvider>()
          .fetchFarmerMilkCollection();

      // Get the raw data from provider
      final rawData =
          context.read<FarmerMilkCollectionProvider>().farmerMilkList;

      // Transform the data structure
      List<Map<String, dynamic>> transformedList = [];

      // Each item in rawData represents a farmer's document
      for (var farmerDoc in rawData) {
        // Extract milkEntries array from the document
        List<dynamic> milkEntries = farmerDoc['milkEntries'] ?? [];

        // Convert each entry in milkEntries to the format expected by UI
        for (var entry in milkEntries) {
          if (entry is Map<String, dynamic>) {
            // Each entry is already in the format {timestamp: data}
            transformedList.add(entry);
          }
        }
      }

      // Sort the list by timestamp in descending order
      transformedList.sort((a, b) {
        String dateAString = a.keys.first;
        String dateBString = b.keys.first;

        // Convert timestamp to DateTime
        DateTime dateA = DateFormat('EEEE-dd-MMMM-yyyy').parse(dateAString);
        DateTime dateB = DateFormat('EEEE-dd-MMMM-yyyy').parse(dateBString);

        // Sort in descending order
        return dateB.compareTo(dateA);
      });

      setState(() {
        _list = transformedList;
        _isLoading = false;
      });
    } catch (e) {
      log("Error fetching milk collection data: $e");
      setState(() => _isLoading = false);
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        log("Error parsing double: $e");
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, double> _calculateTotals() {
    double totalQuantity = 0;
    double totalAmount = 0;

    for (var item in _list) {
      try {
        final collection = item.values.first as Map<String, dynamic>;
        totalQuantity += _parseDouble(collection['liters']);
        totalAmount += _parseDouble(collection['total'] ?? '0');
      } catch (e) {
        log("Error calculating totals: $e");
      }
    }

    return {
      'quantity': totalQuantity,
      'amount': totalAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Milk Collection'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Text("No Data"),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Collection Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SummaryItem(
                                title: 'Total Quantity',
                                value:
                                    '${totals['quantity']?.toStringAsFixed(2)} L',
                                icon: Icons.water_drop,
                                color: Colors.blue,
                              ),
                              _SummaryItem(
                                title: 'Total Amount',
                                value:
                                    '₹${totals['amount']?.toStringAsFixed(2)}',
                                icon: Icons.currency_rupee,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final item = _list[index];
                        final date = item.keys.first;
                        final collection = item[date] as Map<String, dynamic>;
                        final milkType = collection['milkType'] as String;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (collection["timeStamp"] ==
                                      DateFormat('EEEE-dd-MMMM-yyyy')
                                          .format(DateTime.now()))
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              backgroundColor: Colors.transparent,
                              title: Text(
                                '${collection["timeStamp"]} - ${collection['deliveryTime']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_parseDouble(collection['liters']).toStringAsFixed(2)} L',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _DetailRow(
                                        'Milk Type',
                                        milkType,
                                        icon: Icons.category,
                                      ),
                                      _DetailRow(
                                        'Fat Content',
                                        '${_parseDouble(collection['fat']).toStringAsFixed(1)}%',
                                        icon: Icons.opacity,
                                      ),
                                      _DetailRow(
                                        'Rate/L',
                                        '₹${collection['rate']}',
                                        icon: Icons.currency_rupee,
                                      ),
                                      const Divider(height: 24),
                                      _DetailRow(
                                        'Total Amount',
                                        '₹${_parseDouble(collection['total'] ?? '0').toStringAsFixed(2)}',
                                        isTotal: true,
                                        icon: Icons.payments,
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
                  ),
                ],
              ),
            ),
    );
  }
}

// Keep the existing _SummaryItem and _DetailRow widgets as they are
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final IconData icon;

  const _DetailRow(
    this.label,
    this.value, {
    this.isTotal = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isTotal ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
