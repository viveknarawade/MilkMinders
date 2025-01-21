import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../controller/farmer_list_provider.dart';

class AllFarmersReport extends StatefulWidget {
  const AllFarmersReport({super.key});

  @override
  State<AllFarmersReport> createState() => _AllFarmersReportState();
}

class _AllFarmersReportState extends State<AllFarmersReport> {
  @override
  void initState() {
    super.initState();
    // Fetch farmers when screen initializes
    getFarmerList();
  }

  getFarmerList() async {
    log("on get farmer list func");
    await context.read<FarmerListProvider>().fetchFarmersFromDairyOwner();
  }

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
          'All Farmers',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () async {
              final farmers = context.read<FarmerListProvider>().list;
              await _generatePdf(context, farmers);
            },
          ),
        ],
      ),
      body: Consumer<FarmerListProvider>(
        builder: (context, farmerProvider, child) {
          getFarmerList();
          final farmers = farmerProvider.list;

          // Debug print to check the data
          print('Farmers data: $farmers');
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      DairyOwnerSessionData.ownerName ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'CUSTOMER REGISTER',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (farmers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No farmers found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        dataTextStyle: GoogleFonts.poppins(
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Mobile')),
                          DataColumn(label: Text('Milk Type')),
                        ],
                        rows: farmers.map((farmer) {
                          // Debug print for individual farmer data
                          print('Processing farmer: $farmer');

                          return _buildDataRow(
                            farmer['code']?.toString() ?? '',
                            farmer['name']?.toString() ?? '',
                            farmer['Number']?.toString() ?? '',
                            farmer['milkType']?.toString() ?? '',
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(String code, String name, String mobile, String milk) {
    return DataRow(
      cells: [
        DataCell(Text(code)),
        DataCell(Text(name)),
        DataCell(Text(mobile)),
        DataCell(Text(milk)),
      ],
    );
  }

  Future<void> _generatePdf(
      BuildContext context, List<Map<String, dynamic>> farmers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                DairyOwnerSessionData.ownerName ?? '',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'CUSTOMER REGISTER',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Code', 'Name', 'Mobile', 'Milk Type'],
                data: farmers.map((farmer) {
                  return [
                    farmer['code']?.toString() ?? '',
                    farmer['name']?.toString() ?? '',
                    farmer['Number']?.toString() ?? '',
                    farmer['milkType']?.toString() ?? '',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    try {
      final Uint8List pdfFile = await pdf.save();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfFile,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
