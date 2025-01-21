import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class MilkCollectionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _milkCollectionsList = [];
  List<Map<String, dynamic>> _filteredCollectionsList = [];
  bool isLoading = false;
  String? error;
  DateTime? _selectedDate;

  List<Map<String, dynamic>> get collectionList => _filteredCollectionsList;
  DateTime? get selectedDate => _selectedDate;

  final FirestoreService _firestoreService = FirestoreService();
  final DateFormat _dateFormat = DateFormat('EEEE-dd-MMMM-yyyy');

  String formatDateForFirestore(DateTime date) {
    return _dateFormat.format(date);
  }

  DateTime? parseFirestoreDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (e) {
      log("Error parsing date: $dateStr");
      try {
        return DateFormat('EEEE-d-MMMM-yyyy').parse(dateStr);
      } catch (e) {
        log("Failed to parse date with alternative format: $dateStr");
        return null;
      }
    }
  }

  Future<void> fetchMilkCollectionData() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      var rawData = await _firestoreService.getAllFarmersMilkData();
      
      _milkCollectionsList = [];

      // Process each farmer's document
      for (var farmerDoc in rawData) {
        // Check if milkEntries exists and is a list
        if (farmerDoc['milkEntries'] != null && farmerDoc['milkEntries'] is List) {
          // Process each entry in milkEntries
          for (var entry in farmerDoc['milkEntries']) {
            if (entry is Map) {
              // Each entry should have a single key-value pair where key is timestamp
              entry.forEach((timestamp, data) {
                if (data is Map) {
                  // Add the timestamp to the data for easier access
                  Map<String, dynamic> collectionData = Map<String, dynamic>.from(data);
                  collectionData['timeStamp'] = timestamp;
                  _milkCollectionsList.add(collectionData);
                  
                  log("Added collection data for timestamp: $timestamp");
                }
              });
            }
          }
        }
      }

      // Set selected date to today and format it correctly
      _selectedDate = DateTime.now();
      String todayFormatted = formatDateForFirestore(_selectedDate!);
      log("Today's formatted date: $todayFormatted");

      _applyFilters();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = "Failed to load milk collection data";
      log("Error fetching milk collection: $e");
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime? date) {
    if (date != null) {
      _selectedDate = DateTime(date.year, date.month, date.day);
      log("Set selected date to: ${formatDateForFirestore(_selectedDate!)}");
    } else {
      _selectedDate = null;
    }
    _applyFilters();
  }

  void _applyFilters({
    bool? isMorningSelected,
    bool? isEveningSelected,
    bool? isCowSelected,
    bool? isBuffaloSelected,
  }) {
    _filteredCollectionsList = _milkCollectionsList.where((collection) {
      // Debug print for date comparison
      if (_selectedDate != null) {
        String collectionDateStr = collection['timeStamp'] as String;
        log("Comparing dates - Collection: $collectionDateStr, Selected: ${formatDateForFirestore(_selectedDate!)}");
      }

      // First filter by date
      if (_selectedDate != null) {
        String collectionDateStr = collection['timeStamp'] as String;
        DateTime? collectionDate = parseFirestoreDate(collectionDateStr);
        
        if (collectionDate == null) return false;
        
        bool isSameDate = collectionDate.year == _selectedDate!.year &&
            collectionDate.month == _selectedDate!.month &&
            collectionDate.day == _selectedDate!.day;
            
        if (!isSameDate) return false;
      }

      // Apply other filters
      if (isMorningSelected != null && !isMorningSelected && collection['deliveryTime'] == 'Morning') {
        return false;
      }
      if (isEveningSelected != null && !isEveningSelected && collection['deliveryTime'] == 'Evening') {
        return false;
      }
      if (isCowSelected != null && !isCowSelected && collection['milkType'] == 'Cow') {
        return false;
      }
      if (isBuffaloSelected != null && !isBuffaloSelected && collection['milkType'] == 'Buffalo') {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void filterMilkData({
    bool? isMorningSelected,
    bool? isEveningSelected,
    bool? isCowSelected,
    bool? isBuffaloSelected,
  }) {
    _applyFilters(
      isMorningSelected: isMorningSelected,
      isEveningSelected: isEveningSelected,
      isCowSelected: isCowSelected,
      isBuffaloSelected: isBuffaloSelected,
    );
  }
}