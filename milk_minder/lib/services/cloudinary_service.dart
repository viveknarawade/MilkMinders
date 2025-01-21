import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

// Uploading file to Cloudinary and returning the URL
Future<String?> uploadToCloudinary(File img) async {
  if (img == null || img.path.isEmpty) {
    log("No file selected");
    return null;
  }

  try {
    String cloudName = "dzxiekmtk";
    if (cloudName.isEmpty) {
      log("Cloudinary cloud name is not set in .env file");
      return null;
    }

    var uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");

    var request = http.MultipartRequest("POST", uri);

    // Read file bytes
    var fileBytes = await img.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: img.path.split("/").last,
    );

    request.files.add(multipartFile);

    // Set additional fields
    request.fields["upload_preset"] = "preset-for-file-upload";
    request.fields['resource_type'] = "raw";

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      // Extract secure URL
      String? secureUrl = jsonResponse['secure_url'];
      log("Upload successful: $secureUrl");

      return secureUrl;
    } else {
      var errorBody = await response.stream.bytesToString();
      log("Upload failed: $errorBody");
      return null;
    }
  } catch (e) {
    log("Error during upload: $e");
    return null;
  }
}
