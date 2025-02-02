import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FarmerMilkCollectionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _farmerList = [];
  List<Map<String, dynamic>> _selectedFarmerList = [];

  List<Map<String, dynamic>> get farmerMilkList => _farmerList;
  List<Map<String, dynamic>> get selectedFarmerMilkList => _selectedFarmerList;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> fetchFarmerMilkCollection() async {
    try {
      log("milk collection fetch");
      final List<Map<String, dynamic>> _farmersMilkList =
          await _firestoreService.getFarmerMilkCollection();

      _farmerList = _farmersMilkList;

      log("in provider farmer milk collection  = ${_farmersMilkList}");
      notifyListeners();
    } catch (e) {
      log("Error fetching farmers: $e");
      _farmerList = [];
      notifyListeners();
    }
  }

  getBillData(String id) async {
    _selectedFarmerList = await _firestoreService.getFarmerMilkData(id);
    notifyListeners();
  }
  
}
