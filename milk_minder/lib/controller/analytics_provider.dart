import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class AnalyticsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;
  String? error;

  double totalCollection = 0;
  double totalEarnings = 0;
  double cowMilkTotal = 0;
  double buffaloMilkTotal = 0;
  List<MapEntry<String, double>> collectionTrend = [];
  List<MapEntry<String, double>> earningsTrend = [];

  double previousCollection = 0;
  double previousEarnings = 0;

  Future<void> fetchAnalyticsData(String period) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      List<Map<String, dynamic>> rawData =
          await _firestoreService.getAllFarmersMilkData();

      _processData(rawData, period);
      _processPreviousPeriodData(rawData, period);
      _calculateTrends(rawData, period);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error in fetchAnalyticsData: $e');
      error = 'Failed to load analytics data';
      isLoading = false;
      notifyListeners();
    }
  }

  void _processData(List<Map<String, dynamic>> rawData, String period) {
    totalCollection = 0;
    totalEarnings = 0;
    cowMilkTotal = 0;
    buffaloMilkTotal = 0;

    for (var farmerData in rawData) {
      List<dynamic> milkEntries = farmerData['milkEntries'] ?? [];

      for (var entry in milkEntries) {
        entry.forEach((timestamp, data) {
          if (_isWithinPeriod(timestamp, period)) {
            // Safe parsing of numeric values
            double liters = _safeParseDouble(data['liters']) ?? 0;
            double total = _safeParseDouble(data['total']) ?? 0;
            String milkType = (data['milkType'] ?? '').toString().toLowerCase();

            totalCollection += liters;
            totalEarnings += total;

            if (milkType == 'cow') {
              cowMilkTotal += liters;
            } else if (milkType == 'buffalo') {
              buffaloMilkTotal += liters;
            }
          }
        });
      }
    }
  }

  void _processPreviousPeriodData(
      List<Map<String, dynamic>> rawData, String period) {
    previousCollection = 0;
    previousEarnings = 0;

    for (var farmerData in rawData) {
      List<dynamic> milkEntries = farmerData['milkEntries'] ?? [];

      for (var entry in milkEntries) {
        entry.forEach((timestamp, data) {
          if (_isWithinPreviousPeriod(timestamp, period)) {
            // Safe parsing of numeric values
            double liters = _safeParseDouble(data['liters']) ?? 0;
            double total = _safeParseDouble(data['total']) ?? 0;

            previousCollection += liters;
            previousEarnings += total;
          }
        });
      }
    }
  }

  void _calculateTrends(List<Map<String, dynamic>> rawData, String period) {
    Map<String, double> dailyCollection = {};
    Map<String, double> dailyEarnings = {};

    for (var farmerData in rawData) {
      List<dynamic> milkEntries = farmerData['milkEntries'] ?? [];

      for (var entry in milkEntries) {
        entry.forEach((timestamp, data) {
          if (_isWithinPeriod(timestamp, period)) {
            DateTime date = _parseDate(timestamp);
            String dateKey = DateFormat('yyyy-MM-dd').format(date);

            // Safe parsing of numeric values
            double liters = _safeParseDouble(data['liters']) ?? 0;
            double total = _safeParseDouble(data['total']) ?? 0;

            dailyCollection[dateKey] = (dailyCollection[dateKey] ?? 0) + liters;
            dailyEarnings[dateKey] = (dailyEarnings[dateKey] ?? 0) + total;
          }
        });
      }
    }

    collectionTrend = dailyCollection.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    earningsTrend = dailyEarnings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  // Helper method to safely parse double values
  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        log('Error parsing double: $value');
        return null;
      }
    }
    return null;
  }

  // Helper method to parse dates consistently
  DateTime _parseDate(String timestamp) {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      try {
        return DateFormat('EEEE-dd-MMMM-yyyy').parse(timestamp);
      } catch (e) {
        log('Error parsing date: $timestamp');
        return DateTime.now(); // Fallback to current date
      }
    }
  }

  bool _isWithinPeriod(String timestamp, String period) {
    DateTime date = _parseDate(timestamp);
    DateTime now = DateTime.now();

    switch (period.toLowerCase()) {
      case 'week':
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 'month':
        return date.isAfter(now.subtract(const Duration(days: 30)));
      case 'year':
        return date.isAfter(now.subtract(const Duration(days: 365)));
      default:
        return false;
    }
  }

  bool _isWithinPreviousPeriod(String timestamp, String period) {
    DateTime date = _parseDate(timestamp);
    DateTime now = DateTime.now();

    switch (period.toLowerCase()) {
      case 'week':
        DateTime periodStart = now.subtract(const Duration(days: 7));
        DateTime previousStart = periodStart.subtract(const Duration(days: 7));
        return date.isAfter(previousStart) && date.isBefore(periodStart);
      case 'month':
        DateTime periodStart = now.subtract(const Duration(days: 30));
        DateTime previousStart = periodStart.subtract(const Duration(days: 30));
        return date.isAfter(previousStart) && date.isBefore(periodStart);
      case 'year':
        DateTime periodStart = now.subtract(const Duration(days: 365));
        DateTime previousStart =
            periodStart.subtract(const Duration(days: 365));
        return date.isAfter(previousStart) && date.isBefore(periodStart);
      default:
        return false;
    }
  }

  double getCollectionGrowth() {
    if (previousCollection == 0) return 0;
    return ((totalCollection - previousCollection) / previousCollection) * 100;
  }

  double getEarningsGrowth() {
    if (previousEarnings == 0) return 0;
    return ((totalEarnings - previousEarnings) / previousEarnings) * 100;
  }

  double getCowMilkPercentage() {
    if (totalCollection == 0) return 0;
    return (cowMilkTotal / totalCollection) * 100;
  }

  double getBuffaloMilkPercentage() {
    if (totalCollection == 0) return 0;
    return (buffaloMilkTotal / totalCollection) * 100;
  }

  double getCowMilkLiters() => cowMilkTotal;
  double getBuffaloMilkLiters() => buffaloMilkTotal;

  List<MapEntry<String, double>> getCollectionTrend() => collectionTrend;
  List<MapEntry<String, double>> getEarningsTrend() => earningsTrend;
}
