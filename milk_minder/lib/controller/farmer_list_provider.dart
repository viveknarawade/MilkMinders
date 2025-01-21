import 'dart:developer';

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class FarmerListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _farmersList = [];
  List<Map<String, dynamic>> _filteredFarmersList = [];

  List<Map<String, dynamic>> get list =>
      _filteredFarmersList.isEmpty ? _farmersList : _filteredFarmersList;

  final FirestoreService _firestoreService = FirestoreService();

  // Method to fetch farmers from Firestore for the current dairy owner
  Future<void> fetchFarmersFromDairyOwner() async {
    try {
      final List<Map<String, dynamic>> farmers =
          await _firestoreService.getFarmersFromDairyOwner();
      _farmersList = farmers;
      _filteredFarmersList = farmers; // Initially, show all farmers

      notifyListeners();
    } catch (e) {
      log("Error fetching farmers: $e");
    }
  }

  // Method to filter farmers based on search query
  void filterFarmers(String query) {
    if (query.isEmpty) {
      _filteredFarmersList.clear();
    } else {
      _filteredFarmersList = _farmersList
          .where((farmer) =>
              (farmer["name"] as String).contains(query) ||
              (farmer["code"] as String).contains(query))
          .toList();
    }
    notifyListeners();
  }
}
