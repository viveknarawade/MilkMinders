import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../controller/farmer_milk_collection_provider.dart';
import '../../../services/dairy_owner_session_data.dart';

class FarmerBillScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;
  const FarmerBillScreen({required this.farmer, Key? key}) : super(key: key);

  @override
  State<FarmerBillScreen> createState() => _FarmerBillScreenState();
}

class _FarmerBillScreenState extends State<FarmerBillScreen> {
  String selectedValue = "January 2025";
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  double totalAmount = 0.0;
  double totalLiters = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FarmerMilkCollectionProvider>()
          .getBillData(widget.farmer["id"]);
    });
  }

  // Helper method to safely parse double values
  double parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        log('Error parsing double value: $value');
        return 0.0;
      }
    }
    return 0.0;
  }

  void processData(List<Map<String, dynamic>> data) {
    try {
      groupedData.clear();
      totalAmount = 0.0;
      totalLiters = 0.0;

      final selectedMonth = selectedValue.split(" ")[0];
      final selectedYear = selectedValue.split(" ")[1];

      if (data.isEmpty || data[0]['milkEntries'] == null) {
        log('No milk entries found in data');
        return;
      }

      final List<dynamic> entries = data[0]['milkEntries'];

      for (var entry in entries) {
        entry.forEach((dateString, details) {
          try {
            final dateParts = dateString.split('-');
            if (dateParts.length >= 4) {
              final day = dateParts[1];
              final month = dateParts[2];
              final year = dateParts[3];

              if (month == selectedMonth && year == selectedYear) {
                if (!groupedData.containsKey(day)) {
                  groupedData[day] = [];
                }

                // Ensure details is properly typed and contains required fields
                if (details is Map<String, dynamic>) {
                  // Sanitize the data before adding
                  final sanitizedDetails = {
                    ...details,
                    'liters': parseDoubleValue(details['liters']),
                    'fat': parseDoubleValue(details['fat']),
                    'rate': parseDoubleValue(details['rate']),
                    'total': parseDoubleValue(details['total']),
                    'deliveryTime': details['deliveryTime'] ?? 'Unknown',
                  };

                  groupedData[day]!.add(sanitizedDetails);
                  totalAmount += sanitizedDetails['total'] as double;
                  totalLiters += sanitizedDetails['liters'] as double;
                }
              }
            }
          } catch (e) {
            log('Error processing entry: $e');
            // Continue processing other entries even if one fails
          }
        });
      }

      // Sort the days numerically
      var sortedKeys = groupedData.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      groupedData = {for (var key in sortedKeys) key: groupedData[key]!};

      setState(() {});
    } catch (e) {
      log('Error in processData: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Define custom styles
    final headerStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green900,
    );

    final subHeaderStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    final tableHeaderStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green900,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(DairyOwnerSessionData.dairyName ?? "Dairy Name",
                    style: headerStyle),
                pw.Text("Bill for $selectedValue", style: subHeaderStyle),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Farmer Details
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Farmer Details", style: subHeaderStyle),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Name: ${widget.farmer["name"]}"),
                    pw.Text("Code: ${widget.farmer["code"]}"),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text("Total Liters", style: subHeaderStyle),
                    pw.SizedBox(height: 5),
                    pw.Text(totalLiters.toStringAsFixed(2)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text("Total Amount", style: subHeaderStyle),
                    pw.SizedBox(height: 5),
                    pw.Text("₹${totalAmount.toStringAsFixed(2)}"),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Collection Table
          _buildPDFTable(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFTable() {
    try {
      return pw.Table.fromTextArray(
        border: null,
        headerDecoration: const pw.BoxDecoration(
          color: PdfColors.green100,
        ),
        headerHeight: 30,
        cellHeight: 25,
        cellAlignment: pw.Alignment.center,
        headerStyle: pw.TextStyle(
          color: PdfColors.green900,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          fontSize: 10,
        ),
        headers: [
          'Date',
          'Morning\nLiters',
          'Morning\nFat',
          'Morning\nAmount',
          'Evening\nLiters',
          'Evening\nFat',
          'Evening\nAmount',
          'Total\nLiters',
          'Total\nAmount'
        ],
        data: groupedData.entries.map((entry) {
          final day = entry.key;
          final dayData = entry.value;
          Map<String, dynamic> morningData = {};
          Map<String, dynamic> eveningData = {};
          double dayTotalLiters = 0;
          double dayTotalAmount = 0;

          for (var entry in dayData) {
            if (entry['deliveryTime'] == 'Morning') {
              morningData = entry;
            } else if (entry['deliveryTime'] == 'Evening') {
              eveningData = entry;
            }
            dayTotalLiters += parseDoubleValue(entry['liters']);
            dayTotalAmount += parseDoubleValue(entry['total']);
          }

          return [
            day.padLeft(2, '0'),
            morningData['liters']?.toStringAsFixed(2) ?? '-',
            morningData['fat']?.toStringAsFixed(2) ?? '-',
            morningData['total']?.toStringAsFixed(2) ?? '-',
            eveningData['liters']?.toStringAsFixed(2) ?? '-',
            eveningData['fat']?.toStringAsFixed(2) ?? '-',
            eveningData['total']?.toStringAsFixed(2) ?? '-',
            dayTotalLiters.toStringAsFixed(2),
            dayTotalAmount.toStringAsFixed(2),
          ];
        }).toList(),
      );
    } catch (e) {
      log('Error building PDF table: $e');
      // Return an empty table with headers in case of error
      return pw.Table.fromTextArray(
        headers: ['Date', 'No data available'],
        data: [
          ['', '']
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Consumer<FarmerMilkCollectionProvider>(
        builder: (context, provider, child) {
          final data = provider.selectedFarmerMilkList;

          if (data.isNotEmpty && groupedData.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              processData(data);
            });
          }

          if (data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildHeaderInfo(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildCollectionTable(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF40A98D),
      title: Text(
        "Milk Collection Bill",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.print, color: Colors.white),
          onPressed: _generatePDF,
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          underline: Container(),
          icon: const Icon(Icons.calendar_month, color: Color(0xFF40A98D)),
          items: [
            "January 2025",
            "February 2025",
            "March 2025",
            "April 2025",
            "May 2025",
            "June 2025",
            "July 2025",
            "August 2025",
            "September 2025",
            "October 2025",
            "November 2025",
            "December 2025",
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedValue = newValue;
                processData(context
                    .read<FarmerMilkCollectionProvider>()
                    .selectedFarmerMilkList);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem("Total Liters", totalLiters.toStringAsFixed(2)),
            Container(height: 50, width: 1, color: Colors.grey[300]),
            _buildSummaryItem(
                "Total Amount", "₹${totalAmount.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF40A98D),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DairyOwnerSessionData.dairyName!,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF40A98D),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Farmer code : ${widget.farmer["code"]}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Milk Type: Both",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Name: ${widget.farmer["name"]}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Duration: month",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF40A98D).withOpacity(0.1),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildHeaderCell("Date", width: 80),
            _buildVerticalDivider(),
            Column(
              children: [
                Container(
                  width: 320,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Text(
                    "Morning",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    _buildHeaderCell("Liter", width: 80),
                    _buildHeaderCell("Fat", width: 80),
                    _buildHeaderCell("Rate", width: 80),
                    _buildHeaderCell("Total", width: 80),
                  ],
                ),
              ],
            ),
            _buildVerticalDivider(),
            Column(
              children: [
                Container(
                  width: 320,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Text(
                    "Evening",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    _buildHeaderCell("Liter", width: 80),
                    _buildHeaderCell("Fat", width: 80),
                    _buildHeaderCell("Rate", width: 80),
                    _buildHeaderCell("Total", width: 80),
                  ],
                ),
              ],
            ),
            _buildVerticalDivider(),
            _buildHeaderCell("Total\nLiters", width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String day, List<Map<String, dynamic>> dayData) {
    try {
      Map<String, dynamic> morningData = {};
      Map<String, dynamic> eveningData = {};
      double totalLiters = 0;

      for (var entry in dayData) {
        if (entry['deliveryTime'] == 'Morning') {
          morningData = entry;
        } else if (entry['deliveryTime'] == 'Evening') {
          eveningData = entry;
        }
        totalLiters += parseDoubleValue(entry['liters']);
      }

      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildDataCell(day.padLeft(2, '0'), 80),
              _buildDataCell(
                  morningData['liters']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(morningData['fat']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(
                  morningData['rate']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(
                  morningData['total']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(
                  eveningData['liters']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(eveningData['fat']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(
                  eveningData['rate']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(
                  eveningData['total']?.toStringAsFixed(2) ?? '-', 80),
              _buildDataCell(totalLiters.toStringAsFixed(2), 100),
            ],
          ),
        ),
      );
    } catch (e) {
      log('Error building data row: $e');
      return Container(); // Return empty container in case of error
    }
  }

  Widget _buildCollectionTable() {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(),
              ...groupedData.entries.map((entry) {
                final day = entry.key;
                final dayData = entry.value;
                return _buildDataRow(day, dayData);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(text, style: GoogleFonts.poppins()),
    );
  }

  Widget _buildVerticalDivider() {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: Colors.grey.shade300,
    );
  }
}
