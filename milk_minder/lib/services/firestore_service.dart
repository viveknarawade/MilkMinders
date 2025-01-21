import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';
import 'package:milk_minder/services/farmer_session_data.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

// to get owner id
  Future<String> getOwnerID() async {
    DocumentSnapshot farmerDoc =
        await firestore.collection("Farmer").doc(FarmerSessionData.fid).get();

    var farmerData = farmerDoc.data() as Map<String, dynamic>;
    String ownerId = farmerData["ownerId"];
    log("Owner ID: $ownerId");
    return ownerId;
  }

// Add user data to Firestore
  Future<void> addFarmerData(Map<String, dynamic> farmerData) async {
    // Save Farmer
    log(farmerData["fid"]);

    await firestore.collection("Farmer").doc(farmerData["fid"]).set(farmerData);
    log("farmer added");
  }

  Future<void> addDairyOwnerData(
      {required String email,
      required String name,
      required String number,
      required String profilePic,
      required String address,
      required String dairyName,
      required String DId}) async {
    Map<String, dynamic> data = {
      "UserName": name,
      "Number": number,
      "ProfilePic": profilePic,
      "email": email,
      "Address": address,
      "DairyName": dairyName,
      "role": "dairyOwner",
      "ownerId": DId
    };

    // Save Diary Owner
    await firestore.collection("DiaryOwner").doc(DId).set(data);
  }

// add farmer to scecific dairy owner
  addFarmerToDairyOwner(Map<String, dynamic> farmerData) async {
    final refDoc =
        await firestore.collection("DiaryOwner").doc(DairyOwnerSessionData.id);

    await refDoc.collection("Farmer").doc(farmerData["id"]).set(farmerData);
    log("farmer added to diary owner");

    await firestore
        .collection("Farmer")
        .doc(farmerData["id"])
        .update({"ownerId": DairyOwnerSessionData.id});

    log("dairy owner id ${DairyOwnerSessionData.id} is  added to farmer");
  }

// fetch farmer from dairy owner
  getFarmersFromDairyOwner() async {
    QuerySnapshot snapshot = await firestore
        .collection("DiaryOwner")
        .doc(DairyOwnerSessionData.id)
        .collection("Farmer")
        .get();

    List<Map<String, dynamic>> data = [];

    for (var x in snapshot.docs) {
      data.add(x.data() as Map<String, dynamic>);
    }
    log("farmer added to diary owner${data}");
    return data;
  }

  setRates(Map<String, dynamic> rate) async {
    final refDoc = await firestore
        .collection("DiaryOwner")
        .doc(DairyOwnerSessionData.id)
        .collection("Rate")
        .doc(DairyOwnerSessionData.id)
        .set(rate);

    log("rate set");
  }

// getFarmer from farmer collection
  getFarmerListFromFarmer() async {
    List<Map<String, dynamic>> farmerData = [];
    QuerySnapshot snapshot = await firestore.collection("Farmer").get();

    for (var c in snapshot.docs) {
      // Add document ID to the farmer data
      Map<String, dynamic> farmer = c.data() as Map<String, dynamic>;
      farmer['id'] = c.id; // Add the document ID to the data

      farmerData.add(farmer);
    }

    return farmerData;
  }

  /// get farmer id by mobile number
  Future<String?> getFarmerIdByMobileNumber(String mobileNumber) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection("Farmer")
          .where("number", isEqualTo: mobileNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        log(snapshot.docs.first.id);
        return snapshot.docs.first.id;
      } else {
        log("farmer  not found");
        return null;
      }
    } catch (e) {
      // Handle any errors
      log("Error fetching farmer ID: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllFarmersMilkData() async {
    List<Map<String, dynamic>> data = [];
    try {
      // Reference to the milkData collection
      CollectionReference milkDataRef = firestore
          .collection("MilkCollected")
          .doc(DairyOwnerSessionData.id)
          .collection("milkData");

      // Fetch all farmers' data
      QuerySnapshot milkDataSnapshot = await milkDataRef.get();

      // Process each document
      for (var doc in milkDataSnapshot.docs) {
        data.add(doc.data() as Map<String, dynamic>);
      }

      return data;
    } catch (e) {
      log('Error fetching milk data: $e');
      return [];
    }
  }


Future<void> addMilkCollectedData(Map<String, dynamic> milkData) async {
  try {
    // Get the farmer ID by mobile number
    String? farmerId = await getFarmerIdByMobileNumber(milkData["number"]);
    log("Farmer ID: $farmerId");

    if (farmerId == null) {
      throw Exception("Farmer ID not found");
    }

    // Create the data structure
    String timeStamp = milkData["timeStamp"];
    Map<String, dynamic> data = {
      "deliveryTime": milkData["deliveryTime"],
      "farmerId": farmerId,
      "farmerName": milkData["farmerName"],
      "fat": milkData["fat"],
      "liters": milkData["liters"],
      "milkType": milkData["milkType"],
      "number": milkData["number"],
      "rate": milkData["rate"],
      "total": milkData["total"],
      "timeStamp": timeStamp,
    };

    // Create the timestamp-keyed entry
    Map<String, dynamic> newEntry = {timeStamp: data};

    // Reference to the milk collection document
    DocumentReference milkCollectionRef = firestore
        .collection("MilkCollected")
        .doc(DairyOwnerSessionData.id)
        .collection("milkData")
        .doc(farmerId);

    // Fetch existing entries
    DocumentSnapshot snapshot = await milkCollectionRef.get();
    List<dynamic> milkEntries = [];

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> existingData = snapshot.data() as Map<String, dynamic>;
      milkEntries = List<dynamic>.from(existingData["milkEntries"] ?? []);
    }

    // Append the new entry to the list
    milkEntries.add(newEntry);

    // Update Firestore with the updated list
    await milkCollectionRef.set(
      {
        "milkEntries": milkEntries,
      },
      SetOptions(merge: true),
    );

    log("Milk collection data added successfully");
  } catch (e) {
    log("Error adding milk collection data: $e");
    rethrow;
  }
}


// toget rate
  getRate() async {
    List<Map<String, dynamic>> rateList = [];
    String? ownerID = await getOwnerID();

    QuerySnapshot snapshot = await firestore
        .collection("DiaryOwner")
        .doc(ownerID)
        .collection("Rate")
        .get();

    for (var element in snapshot.docs) {
      rateList.add(element.data() as Map<String, dynamic>);
    }

    Map<String, dynamic> rataMap = {
      "Cow": rateList[0]["Cow"],
      "Buffalo": rateList[0]["Buffalo"],
    };

    log(rataMap.toString());
    return rataMap;
  }

// get secific  farmer milk collection
  getFarmerMilkCollection() async {
    List<Map<String, dynamic>> farmerMilkCollection = [];

    String? ownerID = await getOwnerID();
    DocumentSnapshot snapshot = await firestore
        .collection("MilkCollected")
        .doc(ownerID)
        .collection("milkData")
        .doc(FarmerSessionData.fid)
        .get();
    farmerMilkCollection.add(snapshot.data() as Map<String, dynamic>);
    log("in  fetch func firestore service = $farmerMilkCollection");
    return farmerMilkCollection;
  }
}
