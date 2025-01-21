import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milk_minder/services/cloudinary_service.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';
import 'package:milk_minder/services/farmer_session_data.dart';
import 'package:milk_minder/services/firestore_service.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Register Farmer
  Future<User?> registerFarmer(Map<String, dynamic> data) async {
    try {
      // Create a new user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: data["email"],
        password: data["password"],
      );

      // Upload image to Cloudinary
      String? picUrl = await uploadToCloudinary(data["profilePic"]);
      if (picUrl == null) {
        log("Error uploading profile picture");
        return null;
      }

      // Update data with the uploaded image URL
      data["profilePic"] = picUrl;
      data["fid"] = userCredential.user!.uid;
      log(data["fid"]);
      log(userCredential.user!.uid);

      // Add user data to Firestore
      await FirestoreService().addFarmerData(data);
      log("New farmer registered successfully");

      return userCredential.user;
    } catch (e) {
      log("Error during user registration: $e");
      return null;
    }
  }

  // Register DairyOwner
  Future registerDairyOwner(String email, String password, String name,
      String number, String address, String dairyName, File profilePic) async {
    try {
      // Create a new Dairy owner
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload image to Cloudinary
      String? picUrl = await uploadToCloudinary(profilePic);
      if (picUrl == null) {
        log("Error uploading profile picture");
        return null;
      }

      // add user data to firestore
      FirestoreService().addDairyOwnerData(
        email: email,
        name: name,
        number: number,
        profilePic: picUrl,
        address: address,
        dairyName: dairyName,
        DId: userCredential.user!.uid,
      );
      log("New Dairy owner created successfully");
      log(userCredential.user!.email.toString());

      // Return the user
      return userCredential.user;
    } catch (e) {
      log("Error during  Dairy owner registration: $e");
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      // Sign in the user with email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      log(userId);

      // Check Farmer collection
      DocumentSnapshot farmerDoc =
          await firestore.collection("Farmer").doc(userId).get();
      if (farmerDoc.exists) {
        Map<String, dynamic> farmerData =
            farmerDoc.data() as Map<String, dynamic>;

        // Extract fields from the farmerData map
        String Name = farmerData['name'] ?? '';
        String cattleType =
            farmerData['cattleType'] ?? ''; // assuming it's available
        String email = farmerData['email'] ?? '';
        String address = farmerData['address'] ?? '';
        String number = farmerData['number'] ?? '';
        String profilePic = farmerData['profilePic'] ?? '';

        // Set session data for Farmer
        await FarmerSessionData.setFarmerSessionData(
          loginData: true,
          role: "Farmer",
          id: userId,
          Name: Name, // Use the extracted 'ownerName' here
          cattleType: cattleType,
          email: email,
          address: address,
          number: number,
          profilePic: profilePic,
        );

        return "Farmer";
      }

      // Check DairyOwner collection
      DocumentSnapshot dairyOwnerDoc =
          await firestore.collection("DiaryOwner").doc(userId).get();
      if (dairyOwnerDoc.exists) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic> dairyOwnerData =
            dairyOwnerDoc.data() as Map<String, dynamic>;

        // Access the fields with the correct keys
        String ownerName = dairyOwnerData['UserName'] ?? '';
        String dairyName = dairyOwnerData['DairyName'] ?? '';
        String email = dairyOwnerData['email'] ?? '';
        String address = dairyOwnerData['Address'] ?? '';
        String number = dairyOwnerData['Number'] ?? '';
        String profilePic = dairyOwnerData['ProfilePic'] ?? '';

        // Set the session data for DairyOwner
        await DairyOwnerSessionData.setDairyOwnerSessionData(
          loginData: true,
          role: "DairyOwner",
          id: userId,
          ownerName: ownerName,
          dairyName: dairyName,
          email: email,
          address: address,
          number: number,
          profilePic: profilePic,
        );

        return "DairyOwner";
      }

      return "Farmer"; // User not found
    } catch (e) {
      log("Login error: $e");
      return null;
    }
  }
}
