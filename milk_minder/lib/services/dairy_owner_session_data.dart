import 'package:shared_preferences/shared_preferences.dart';

class DairyOwnerSessionData {
  static bool? isLogin;
  static String? role;
  static String? id;
  static String? ownerName;
  static String? dairyName;
  static String? email;
  static String? address;
  static String? number;
  static String? profilePic;

  // Set Session Data
  static Future<void> setDairyOwnerSessionData({
    required bool loginData,
    required String role,
    required String id,
    required String ownerName,
    required String dairyName,
    required String email,
    required String address,
    required String number,
    required String profilePic,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('isLogin', loginData);
    await sharedPreferences.setString('role', role);
    await sharedPreferences.setString('id', id);
    await sharedPreferences.setString('ownerName', ownerName);
    await sharedPreferences.setString('dairyName', dairyName);
    await sharedPreferences.setString('email', email);
    await sharedPreferences.setString('address', address);
    await sharedPreferences.setString('number', number);
    await sharedPreferences.setString('profilePic', profilePic);

    getSessionData();
  }

  // Get Session Data
  static Future<void> getSessionData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Retrieve data and assign to static variables
    isLogin = sharedPreferences.getBool("isLogin") ?? false;
    role = sharedPreferences.getString("role");
    id = sharedPreferences.getString("id");
    ownerName = sharedPreferences.getString("ownerName");
    dairyName = sharedPreferences.getString("dairyName");
    email = sharedPreferences.getString("email");
    address = sharedPreferences.getString("address");
    number = sharedPreferences.getString("number");
    profilePic = sharedPreferences.getString("profilePic");
  }

  // Clear Session Data
  static Future<void> clearSessionData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();

    // Reset local static variables
    isLogin = false;
    role = null;
  }
}
