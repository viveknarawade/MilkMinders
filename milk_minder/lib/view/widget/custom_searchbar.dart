import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchbar {
  static Widget showCustomSearchbar(
    String title, {
    TextEditingController? controller,
    void Function(String)? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: title,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: Colors.grey[400],
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF40A98D),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
