import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AllFarmersReport extends StatelessWidget {
  const AllFarmersReport({super.key});

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
              await _generatePdf(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Vivek Narawade',
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
                    DataColumn(label: Text('Name English')),
                    DataColumn(label: Text('Mobile')),
                    DataColumn(label: Text('Milk')),
                  ],
                  rows: [
                    _buildDataRow(
                        '1', 'yash Narawade', 'yash', '8605017375', 'C'),
                    _buildDataRow('2', 'satish Narawade', 'satish Narawade',
                        '9307367954', 'B'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String code, String name, String nameEnglish,
      String mobile, String milk) {
    return DataRow(
      cells: [
        DataCell(Text(code)),
        DataCell(Text(name)),
        DataCell(Text(nameEnglish)),
        DataCell(Text(mobile)),
        DataCell(Text(milk)),
      ],
    );
  }

  // Function to generate PDF
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    
    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Vivek Narawade',
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
                headers: ['Code', 'Name', 'Name English', 'Mobile', 'Milk'],
                data: [
                  ['1', 'yash Narawade', 'yash', '8605017375', 'C'],
                  ['2', 'satish Narawade', 'satish Narawade', '9307367954', 'B'],
                ],
              ),
            ],
          );
        },
      ),
    );

    // Create PDF file as Uint8List
    final Uint8List pdfFile = await pdf.save();

    // Print or save the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfFile,
    );
  }
}
