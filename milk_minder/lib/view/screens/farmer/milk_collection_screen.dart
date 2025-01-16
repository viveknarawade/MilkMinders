import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MilkCollectionScreen extends StatefulWidget {
  const MilkCollectionScreen({super.key});

  @override
  State<MilkCollectionScreen> createState() => _MilkCollectionScreenState();
}

class _MilkCollectionScreenState extends State<MilkCollectionScreen> {
  // Sample data - In real app, this would come from an API or database
  final List<MilkCollection> _collections = [
    MilkCollection(
      date: DateTime.now().subtract(const Duration(days: 1)),
      quantity: 12.5,
      fat: 3.5,
      rate: 45.0,
      shift: 'Morning',
      totalAmount: 562.50,
    ),
    MilkCollection(
      date: DateTime.now().subtract(const Duration(days: 1)),
      quantity: 10.0,
      fat: 3.6,
      rate: 46.0,
      shift: 'Evening',
      totalAmount: 460.00,
    ),
    // Add more sample data as needed
  ];

  @override
  Widget build(BuildContext context) {
    double totalQuantity =
        _collections.fold(0, (sum, item) => sum + item.quantity);
    double totalAmount =
        _collections.fold(0, (sum, item) => sum + item.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Collection'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collection Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryItem(
                        title: 'Total Quantity',
                        value: '${totalQuantity.toStringAsFixed(2)} L',
                      ),
                      _SummaryItem(
                        title: 'Total Amount',
                        value: '₹${totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Collection List
          Expanded(
            child: ListView.builder(
                itemCount: _collections.length,
                itemBuilder: (context, index) {
                  final collection = _collections[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        '${DateFormat('dd MMM yyyy').format(collection.date)} - ${collection.shift}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Quantity: ${collection.quantity.toStringAsFixed(2)} L',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _DetailRow('Fat', '${collection.fat}%'),
                              _DetailRow('Rate', '₹${collection.rate}/L'),
                              const Divider(),
                              _DetailRow(
                                'Total Amount',
                                '₹${collection.totalAmount.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _DetailRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class MilkCollection {
  final DateTime date;
  final String shift;
  final double quantity;
  final double fat;

  final double rate;
  final double totalAmount;

  MilkCollection({
    required this.date,
    required this.shift,
    required this.quantity,
    required this.fat,
    required this.rate,
    required this.totalAmount,
  });
}
